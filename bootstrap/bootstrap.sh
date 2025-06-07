#!/bin/ash
# Bootstrap installer for K2 Improvements
# This script must be run first before any other improvements can be installed
# It sets up the foundation: Entware package manager, better root directory, and clones the main repository

# Change to bootstrap directory and save current location
cd $(dirname $0)
CURDIR=$(pwd)

# Install Entware package manager
echo "Installing Entware package manager..."

sh ./entware/install.sh

# Create root directory on larger storage partition
echo "Setting up repository directory..."
mkdir -p /mnt/UDISK/root
cd /mnt/UDISK/root

# Clean up existing repository if it exists
if [ -d "k2-improvements" ]; then
    echo "Removing existing k2-improvements directory..."
    rm -rf k2-improvements
fi

# Clone the main K2 improvements repository
/opt/bin/git clone https://github.com/kronflux/k2-improvements.git

# Return to bootstrap directory
cd $CURDIR

# Setup better root directory (moves root home to /mnt/UDISK)
echo "Setting up better root directory..."
sh ./better-root/install.sh
