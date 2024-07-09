#!/bin/bash

# Functions
msg_info() {
  local msg="$1"
  echo -e "\033[1;34mINFO:\033[0m $msg"
}

msg_ok() {
  local msg="$1"
  echo -e "\033[1;32mOK:\033[0m $msg"
}

msg_error() {
  local msg="$1"
  echo -e "\033[1;31mERROR:\033[0m $msg"
}

# Check for root privileges
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

# Create directory for Authentik
msg_info "Creating Authentik directory..."
mkdir -p /opt/authentik
cd /opt/authentik
msg_ok "Authentik directory created."

# Create docker-compose.yml
msg_info "Creating docker-compose.yml..."
cat <<EOF > /opt/authentik/docker-compose.yml
version: '3'

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: authentik
      POSTGRES_USER: authentik
      POSTGRES_PASSWORD: authentik
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6
    volumes:
      - redis_data:/data

  server:
    image: goauthentik/server:latest
    environment:
      AUTHENTIK_SECRET_KEY: changeme
      AUTHENTIK_REDIS__HOST: redis
      AUTHENTIK_POSTGRESQL__HOST: postgres
      AUTHENTIK_POSTGRESQL__NAME: authentik
      AUTHENTIK_POSTGRESQL__USER: authentik
      AUTHENTIK_POSTGRESQL__PASSWORD: authentik
    ports:
      - "9000:9000"
    depends_on:
      - postgres
      - redis

volumes:
  postgres_data:
  redis_data:
EOF
msg_ok "docker-compose.yml created."

# Start Authentik
msg_info "Starting Authentik services..."
docker-compose up -d
msg_ok "Authentik services started."

msg_ok "Authentik installation completed. Access it at http://your_server_ip:9000"
