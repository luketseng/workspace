# If you encounter script execution errors, run the following command in PowerShell:
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Function 1: Check and create SSH key
function Initialize-SSHKey {
    Write-Host "=== SSH Key Management ===" -ForegroundColor Green

    $keyPath = if ($IsWindows) { "$env:USERPROFILE\.ssh\id_ed25519.pub" } else { "$HOME/.ssh/id_ed25519.pub" }
    $sshDir = if ($IsWindows) { "$env:USERPROFILE\.ssh" } else { "$HOME/.ssh" }
    $keyFile = if ($IsWindows) { "$env:USERPROFILE\.ssh\id_ed25519" } else { "$HOME/.ssh/id_ed25519" }

    if (Test-Path $keyPath) {
        Write-Host "SSH key already exists at: $keyPath" -ForegroundColor Yellow
        $pubkey = Get-Content $keyPath -Raw | Out-String
        $pubkey = $pubkey.Trim()
        Write-Host "Public key content:" -ForegroundColor Cyan
        Write-Host $pubkey -ForegroundColor White

        $recreate = Read-Host "Do you want to recreate the SSH key? (y/N)"
        if ($recreate -notin @("y", "Y")) {
            return
        }
    }

    # Create .ssh directory if it doesn't exist
    if (-not (Test-Path $sshDir)) {
        try {
            New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
            Write-Host "Created SSH directory: $sshDir" -ForegroundColor Green
        } catch {
            Write-Host "Failed to create SSH directory: $sshDir" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            return
        }
    }

    # Find ssh-keygen
    $sshKeygenCmd = ""
    if (Get-Command ssh-keygen -ErrorAction SilentlyContinue) {
        $sshKeygenCmd = "ssh-keygen"
    } elseif (Get-Command ssh-keygen.exe -ErrorAction SilentlyContinue) {
        $sshKeygenCmd = "ssh-keygen.exe"
    } elseif (Test-Path "C:\Windows\System32\OpenSSH\ssh-keygen.exe") {
        $sshKeygenCmd = "C:\Windows\System32\OpenSSH\ssh-keygen.exe"
    } else {
        Write-Host "Cannot find ssh-keygen or ssh-keygen.exe in PATH. Please install OpenSSH and try again." -ForegroundColor Red
        return
    }

    # Generate SSH key
    & $sshKeygenCmd""

    if (Test-Path $keyPath) {
        Write-Host "SSH key created successfully!" -ForegroundColor Green
        $pubkey = Get-Content $keyPath -Raw | Out-String
        $pubkey = $pubkey.Trim()
        Write-Host "Public key content:" -ForegroundColor Cyan
        Write-Host $pubkey -ForegroundColor White
    } else {
        Write-Host "Failed to create SSH key!" -ForegroundColor Red
        return $null
    }
}

# Function to read SSH key without displaying (for internal use)
function Get-SSHKeyContent {
    $keyPath = if ($IsWindows) { "$env:USERPROFILE\.ssh\id_ed25519.pub" } else { "$HOME/.ssh/id_ed25519.pub" }

    if (Test-Path $keyPath) {
        $pubkey = Get-Content $keyPath -Raw | Out-String
        return $pubkey.Trim()
    } else {
        return $null
    }
}

# Function 2: Add new SSH config entry
function Add-SSHConfig {
    Write-Host "=== Add SSH Config Entry ===" -ForegroundColor Green

    $configPath = "$env:USERPROFILE\.ssh\config"

    # Create config file if it doesn't exist
    if (-not (Test-Path $configPath)) {
        New-Item -ItemType File -Path $configPath -Force | Out-Null
        Write-Host "Created SSH config file: $configPath" -ForegroundColor Green
    }

    # Get user input for new host configuration
    Write-Host "Enter SSH host configuration:" -ForegroundColor Cyan
    $hostAlias = Read-Host "Host alias (e.g., myserver)"
    $hostName = Read-Host "HostName/IP address"
    $userName = Read-Host "Username"
    $port = Read-Host "Port (default: 22)"
    if (-not $port) { $port = "22" }

    # Create config entry
    $configEntry = @"
Host $hostAlias
    HostName $hostName
    User $userName
    Port $port
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

"@

    # Add to config file
    Add-Content -Path $configPath -Value $configEntry

    Write-Host "SSH config entry added successfully!" -ForegroundColor Green
    Write-Host "Added configuration:" -ForegroundColor Cyan
    Write-Host $configEntry -ForegroundColor White
}

# Function 3: Read config and select hosts for key distribution
function Select-And-DistributeKeys {
    Write-Host "=== Host Selection and Key Distribution ===" -ForegroundColor Green

    $configPath = "$env:USERPROFILE\.ssh\config"

    if (-not (Test-Path $configPath)) {
        Write-Host "SSH config file not found at: $configPath" -ForegroundColor Red
        Write-Host "Please add SSH config entries first using option 2." -ForegroundColor Yellow
        return
    }

    # Get SSH public key (without displaying)
    $pubkey = Get-SSHKeyContent
    if (-not $pubkey) {
        Write-Host "SSH key not found! Please create SSH key first using option 1." -ForegroundColor Red
        return
    }

    # Parse SSH config and collect host info
    $configLines = Get-Content $configPath
    $hosts = @()
    $current = @{}

    foreach ($line in $configLines) {
        if ($line -match '^Host\s+(\S+)') {
            if ($current.Host) { $hosts += [PSCustomObject]$current }
            $current = @{}
            $current.Host = $Matches[1]
        } elseif ($line -match '^\s*HostName\s+(\S+)') {
            $current.HostName = $Matches[1]
        } elseif ($line -match '^\s*User\s+(\S+)') {
            $current.User = $Matches[1]
        }
    }
    if ($current.Host) { $hosts += [PSCustomObject]$current }

    if ($hosts.Count -eq 0) {
        Write-Host "No hosts found in SSH config!" -ForegroundColor Red
        Write-Host "Please add SSH config entries first using option 2." -ForegroundColor Yellow
        return
    }

    # Show hosts for selection
    Write-Host "Available SSH hosts:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $hosts.Count; $i++) {
        Write-Host ("[$i] {0} ({1}@{2})" -f $hosts[$i].Host, $hosts[$i].User, $hosts[$i].HostName) -ForegroundColor White
    }

    # Prompt user to select hosts by number
    $selection = Read-Host "Enter the numbers of the hosts to send public key to (comma separated, e.g. 0,2)"
    $selectedIndexes = $selection -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }

    $successCount = 0
    foreach ($idx in $selectedIndexes) {
        if ($idx -ge 0 -and $idx -lt $hosts.Count) {
            $h = $hosts[$idx]
            $target = "$($h.User)@$($h.HostName)"
            Write-Host "Sending public key to $target..." -ForegroundColor Yellow

            try {
                # Ensure the key has Unix line endings before sending (without modifying local file)
                $unixKey = $pubkey -replace "`r`n", "`n"

                Write-Host "Debug: Key content to send:" -ForegroundColor Gray
                Write-Host $unixKey -ForegroundColor Gray

                # Use the simple and proven approach: pipe the key content directly
                $unixKey | ssh $target "cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

                Write-Host "Debug: Key sent successfully" -ForegroundColor Gray

                # Clean up any remaining carriage return characters using dos2unix
                Write-Host "Debug: Cleaning up line endings with dos2unix..." -ForegroundColor Gray
                $cleanupResult = ssh $target "dos2unix ~/.ssh/authorized_keys 2>/dev/null || sed -i 's/\r$//' ~/.ssh/authorized_keys" 2>&1
                Write-Host "Debug: Cleanup result:" -ForegroundColor Gray
                Write-Host $cleanupResult -ForegroundColor Gray

                # Verify the key was added correctly
                Write-Host "Debug: Verifying key on remote host..." -ForegroundColor Gray
                $verifyResult = ssh $target "tail -1 ~/.ssh/authorized_keys" 2>&1
                Write-Host "Debug: Verification result:" -ForegroundColor Gray
                Write-Host $verifyResult -ForegroundColor Gray

                if ($verifyResult -and $verifyResult.Trim() -eq $unixKey.Trim()) {
                    Write-Host "Successfully sent key to $target" -ForegroundColor Green
                    $successCount++
                } else {
                    Write-Host "Warning: Key may not have been added correctly to $target" -ForegroundColor Yellow
                    Write-Host "Expected: $($unixKey.Trim())" -ForegroundColor Yellow
                    Write-Host "Got: $($verifyResult.Trim())" -ForegroundColor Yellow
                    Write-Host "You may need to check the authorized_keys file manually" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "Failed to send key to $target" -ForegroundColor Red
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "Exception Type: $($_.Exception.GetType().Name)" -ForegroundColor Red
            }
        } else {
            Write-Host "Invalid host index: $idx" -ForegroundColor Red
        }
    }

    Write-Host "Key distribution completed. Successfully sent to $successCount out of $($selectedIndexes.Count) hosts." -ForegroundColor Cyan
}

# Main menu function
function Show-Menu {
    Clear-Host
    Write-Host "=== SSH Key Management Tool ===" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "1. Check/Create SSH Key" -ForegroundColor White
    Write-Host "2. Add SSH Config Entry" -ForegroundColor White
    Write-Host "3. Select Hosts and Distribute Keys" -ForegroundColor White
    Write-Host "4. Exit" -ForegroundColor White
    Write-Host ""
}

# Main execution
function Main {
    do {
        Show-Menu
        $choice = Read-Host "Please select an option (1-4)"

        switch ($choice) {
            "1" {
                Initialize-SSHKey
                Read-Host "Press Enter to continue..."
            }
            "2" {
                Add-SSHConfig
                Read-Host "Press Enter to continue..."
            }
            "3" {
                Select-And-DistributeKeys
                Read-Host "Press Enter to continue..."
            }
            "4" {
                Write-Host "Goodbye!" -ForegroundColor Green
                return
            }
            default {
                Write-Host "Invalid option. Please select 1-4." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
}

# Start the application
Main