#!/bin/bash

# Bash script to install Bats (Bash Automated Testing System)
set -e

INSTALL_DIR="/usr/local"  # Change this if you want to install elsewhere
REPO_URL="https://github.com/bats-core/bats-core.git"
TEMP_DIR="$(mktemp -d)"

echo "📦 Cloning Bats from GitHub..."
git clone --depth=1 "$REPO_URL" "$TEMP_DIR"

echo "⚙️ Installing Bats to $INSTALL_DIR..."
sudo "$TEMP_DIR/install.sh" "$INSTALL_DIR"

echo " Bats installed successfully!"
echo "Bats version:"
bats --version

# Clean up
rm -rf "$TEMP_DIR"





