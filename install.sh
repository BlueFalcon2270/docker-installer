#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🐳 Starting Universal Docker Installer...${NC}"

# 1. Detect OS and Architecture
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_CODENAME
else
    echo -e "${RED}❌ Cannot detect OS. /etc/os-release not found.${NC}"
    exit 1
fi

echo -e "${GREEN}🔍 Detected OS: $OS${NC}"

# Map RHEL to CentOS for Docker repositories (Common practice as they share binaries)
if [ "$OS" == "rhel" ]; then
    echo -e "${YELLOW}⚠️  RHEL detected. Using CentOS repositories for Docker CE.${NC}"
    REPO_OS="centos"
else
    REPO_OS=$OS
fi

# 2. Installation Logic based on Package Manager
if [[ "$OS" == "ubuntu" || "$OS" == "debian" || "$OS" == "raspbian" ]]; then
    # --- APT BASED SYSTEMS ---
    echo -e "${GREEN}🔄 Updating apt package list...${NC}"
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg

    echo -e "${GREEN}🔑 Adding Docker GPG key...${NC}"
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$REPO_OS/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo -e "${GREEN}📦 Adding Docker Repository for $OS...${NC}"
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$REPO_OS \
      $(lsb_release -cs 2>/dev/null || echo $VERSION) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo -e "${GREEN}⬇️  Installing Docker Engine...${NC}"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

elif [[ "$OS" == "centos" || "$OS" == "fedora" || "$OS" == "rhel" ]]; then
    # --- DNF/YUM BASED SYSTEMS ---
    echo -e "${GREEN}🔄 Installing yum-utils/dnf-plugins-core...${NC}"
    if command -v dnf >/dev/null; then
        sudo dnf -y install dnf-plugins-core
        PKG_MANAGER="dnf"
    else
        sudo yum -y install yum-utils
        PKG_MANAGER="yum"
    fi

    echo -e "${GREEN}📦 Adding Docker Repository for $REPO_OS...${NC}"
    sudo $PKG_MANAGER config-manager --add-repo https://download.docker.com/linux/$REPO_OS/docker-ce.repo

    echo -e "${GREEN}⬇️  Installing Docker Engine...${NC}"
    sudo $PKG_MANAGER install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Enable Docker on RPM systems (it doesn't start auto by default like Debian)
    echo -e "${GREEN}🔌 Enabling Docker Service...${NC}"
    sudo systemctl enable --now docker

else
    echo -e "${RED}❌ Unsupported OS: $OS${NC}"
    echo -e "${YELLOW}This script supports: Debian, Ubuntu, CentOS, Fedora, RHEL, Raspbian.${NC}"
    exit 1
fi

# 3. Final Verification
echo -e "${GREEN}✅ Installation complete! Verifying...${NC}"
sudo docker --version
sudo docker compose version

echo -e "${GREEN}🎉 Done! Docker is ready to use.${NC}"
