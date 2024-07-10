#!/bin/bash

# Functions for message logging
msg_info() {
  echo -e "\033[1;34mINFO:\033[0m $1"
}

msg_ok() {
  echo -e "\033[1;32mOK:\033[0m $1"
}

msg_error() {
  echo -e "\033[1;31mERROR:\033[0m $1"
}

# Ensure the script is run as root
if [[ "$EUID" -ne 0 ]]; then
  msg_error "This script must be run as root"
  exit 1
fi

# Update and install necessary packages
msg_info "Updating system packages..."
apt-get update -y && apt-get upgrade -y
msg_ok "System packages updated."

# Install Docker
msg_info "Installing Docker..."
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
msg_ok "Docker installed."

# Install Docker Compose
msg_info "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
msg_ok "Docker Compose installed."

# Create directories for Authentik
msg_info "Creating Authentik directories..."
mkdir -p /opt/authentik
msg_ok "Authentik directories created."

# Download docker-compose.yml
msg_info "Downloading docker-compose.yml..."
wget -O /opt/authentik/docker-compose.yml https://raw.githubusercontent.com/Marfnl/authentik/main/docker-compose.yml
msg_ok "docker-compose.yml downloaded."

# Start Authentik
msg_info "Starting Authentik services..."
cd /opt/authentik
docker-compose up -d
msg_ok "Authentik services started."

msg_ok "Authentik installation completed. Access it at http://your_server_ip:9000"
