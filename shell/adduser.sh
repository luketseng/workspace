#!/bin/bash

# Prompt user for new username
read -p "Enter username for new user: " USERNAME

# Check if username is empty
if [ -z "$USERNAME" ]; then
    echo "Username cannot be empty. Please try again."
    exit 1
fi

# Check if username already exists
if id "$USERNAME" >/dev/null 2>&1; then
    echo "Username '$USERNAME' already exists. Please try again with a different username."
    exit 1
fi

# Create a new user
adduser "$USERNAME"

# Prompt user whether to add the user to the 'root' group
read -p "Add $USERNAME to 'root' group? [y/N] " ROOT_GROUP

if [[ $ROOT_GROUP =~ ^[Yy]$ ]]; then
    # Add user to 'root' group
    usermod -aG root "$USERNAME"
fi

# Prompt user whether to grant user sudo privileges
read -p "Grant $USERNAME sudo privileges? [y/N] " SUDO_PRIVILEGES

if [[ $SUDO_PRIVILEGES =~ ^[Yy]$ ]]; then
    # Grant new user to run all commands without password
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/"$USERNAME"
fi

# Prompt user whether to install OpenSSH server
read -p "Install OpenSSH server? [y/N] " INSTALL_SSH

if [[ $INSTALL_SSH =~ ^[Yy]$ ]]; then
    # Install OpenSSH server
    apt-get update
    apt-get install -y openssh-server

    # Enable and start OpenSSH service
    systemctl enable ssh
    systemctl start ssh
fi

# Display OpenSSH server status
if [[ $INSTALL_SSH =~ ^[Yy]$ ]]; then
    systemctl status ssh
fi

echo "adduser completed successfully."
