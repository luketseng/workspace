#!/bin/bash

# Check if script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Install Docker dependencies
echo "------- [INFO] Installing Docker dependencies..."
apt update && apt -y install apt-transport-https ca-certificates curl gnupg lsb-release

# Install Docker
echo "------- [INFO] Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || { echo "Failed to download Docker GPG key"; exit 1; }
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null || { echo "Failed to add Docker repository"; exit 1; }
apt update || { echo "Failed to update apt"; exit 1; }
apt install -y docker-ce docker-ce-cli containerd.io || { echo "Failed to install Docker"; exit 1; }
systemctl start docker || { echo "Failed to start Docker service"; exit 1; }


# Check Docker version
echo "------- [INFO] Docker version:"
docker version || { echo "Failed to check Docker version"; exit 1; }

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose || { echo "Failed to download Docker Compose"; exit 1; }
chmod +x /usr/local/bin/docker-compose || { echo "Failed to set executable permissions for Docker Compose"; exit 1; }

# Check docker-compose version
echo "------- [INFO] docker-compose version:"
docker-compose version || { echo "Failed to check docker-compose version"; exit 1; }

# Add root to docker group
echo "------- [INFO] Adding user to Docker group..."
echo "usermod -aG docker $USER"
usermod -aG docker $USER || { echo "Failed to add user to Docker group"; exit 1; }

# Ask $user to docker group
read -p "Enter user name: " USER_NAME
echo "------- [INFO] usermod -aG docker $USER_NAME"
usermod -aG docker $USER_NAME || { echo "Failed to add user to Docker group"; exit 1; }
echo "------- [INFO] Please restart session if docker need sudo permission"

echo "Docker and Docker Compose installation completed successfully."
