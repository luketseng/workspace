#!/bin/bash

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Install Docker dependencies
echo "Installing Docker dependencies..."
sudo apt update && sudo apt -y install apt-transport-https ca-certificates curl gnupg lsb-release

# Install Docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || { echo "Failed to download Docker GPG key"; exit 1; }
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || { echo "Failed to add Docker repository"; exit 1; }
sudo apt update || { echo "Failed to update apt"; exit 1; }
sudo apt install -y docker-ce docker-ce-cli containerd.io || { echo "Failed to install Docker"; exit 1; }
sudo systemctl start docker || { echo "Failed to start Docker service"; exit 1; }

# Add user to docker group
echo "Adding user to Docker group..."
sudo usermod -aG docker $USER || { echo "Failed to add user to Docker group"; exit 1; }

# Check Docker version
echo "Docker version:"
sudo docker version || { echo "Failed to check Docker version"; exit 1; }

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || { echo "Failed to download Docker Compose"; exit 1; }
sudo chmod +x /usr/local/bin/docker-compose || { echo "Failed to set executable permissions for Docker Compose"; exit 1; }

echo "Docker and Docker Compose installation completed successfully."
