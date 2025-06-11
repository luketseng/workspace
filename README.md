# workspace

This repository is my personal backup space, mainly for storing shell configuration files, cold backups, and useful scripts. It is primarily for personal use, but some scripts may be useful for others as well.

## Quick Script Sharing (PowerShell)

You can run the SSH key management PowerShell script from this repository directly using the following command:

```powershell
irm https://raw.githubusercontent.com/luketseng/workspace/refs/heads/master/batch/add_ssh_key.ps1 | iex
```

> **Note:** Please run this command in a PowerShell window with **user privileges** (do not use "Run as Administrator").

- This command downloads and executes the script in one step.
- The script helps you manage SSH keys and distribute them to remote hosts.

## Changelog

- 2025.05.19 Reorganize the directory structure
- 2025.05.11 Update dir and file path
- 2019.09.28 Integrate dir and file
- 2018.08.07 Update server folder
