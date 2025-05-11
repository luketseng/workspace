#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "🛠️ Installing Docker and Docker Compose..."

# 1. Remove old Docker versions if they exist
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# 2. Update package list and install dependencies
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 3. Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4. Set up the Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Update package list again and install Docker Engine and Compose plugin
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Add the current user to the docker group
sudo usermod -aG docker "$USER"

echo "✅ Docker and Docker Compose have been installed successfully!"

# 7. Show installed versions for verification
echo "🔍 Docker version:"
docker --version
echo "🔍 Docker Compose version:"
docker compose version

echo "🔁 Please log out and log back in (or run 'newgrp docker') to apply group changes."
