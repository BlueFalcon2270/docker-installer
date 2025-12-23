#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🐳 Starting Docker Installation...${NC}"

# 1. Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    CODENAME=$VERSION_CODENAME
else
    echo -e "${RED}❌ Cannot detect OS. /etc/os-release not found.${NC}"
    exit 1
fi

echo -e "${GREEN}🔍 Detected OS: $OS ($CODENAME)${NC}"

# Check if OS is supported
if [[ "$OS" != "debian" && "$OS" != "ubuntu" ]]; then
    echo -e "${RED}❌ This script only supports Debian and Ubuntu.${NC}"
    exit 1
fi

# 2. Update and Install Prerequisites
echo -e "${GREEN}🔄 Updating package list and installing prerequisites...${NC}"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 3. Add Docker's Official GPG Key
echo -e "${GREEN}🔑 Adding Docker GPG key...${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Set up the Repository (Dynamic based on OS)
echo -e "${GREEN}📦 Adding Docker Repository for $OS...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
  $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine
echo -e "${GREEN}⬇️  Installing Docker Engine...${NC}"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Verify Installation
echo -e "${GREEN}✅ Installation complete! Verifying...${NC}"
sudo docker --version
sudo docker compose version

echo -e "${GREEN}🎉 Done! Docker is ready to use.${NC}"
