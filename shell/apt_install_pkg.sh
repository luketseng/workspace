#!/bin/bash

#xargs -a pkglist -r sudo apt-get update && sudo apt-get install -y

PKG_LIST="pkglist"

# Check if pkglist file exists
if [ ! -f "$PKG_LIST" ]; then
  echo "------- [FAIL] pkglist file not found. Please create a file named 'pkglist' and list the packages to install."
  exit 1
fi

# Loop through packages in pkglist file
while IFS= read -r pkgname; do
  # Check if package is already installed
  if dpkg-query -W -f='${Status}' "$pkgname" 2>/dev/null | grep -q "installed"; then
    version=$(dpkg-query -W -f='${Version}\n' "$pkgname" 2>/dev/null | awk '{print $0 ? $0 : "null"}')
    echo "------- [INFO] $pkgname (version: $version) is already installed. Skipping installation."
    continue
  fi

  # Install package if it's not installed yet
  echo "------- [INFO] Installing package '$pkgname'..."
  sudo apt-get update
  sudo apt-get install -y "$pkgname"

  # Check if installation was successful
  if [ $? -ne 0 ]; then
    echo "------- [FAIL] Error installing package '$pkgname'."
    exit 1
  fi

  # Display installed version of package
  installed_version=$(dpkg-query -W -f='${Version}' "$pkgname" 2>/dev/null)
  echo "------- [INFO] Package '$pkgname' installed successfully. Version: $installed_version"
done < "$PKG_LIST"
