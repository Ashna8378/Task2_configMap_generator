#!/bin/bash

###########################
# Automate the project to create ConfigMap also run unit test and functional test 
###########################

set -e

SCRIPT="./configMap.sh"
BLUEPRINT="blueprint.xml"
DUMMY="dummy.cfg"
OUTPUT="ConfigMap.yaml"

echo "🔧 Running ConfigMap generator..."
bash "$SCRIPT" "$BLUEPRINT" "$DUMMY"

echo "🛠️ Checking if Git is installed..."
if ! command -v git >/dev/null 2>&1; then
    echo " Git not found. Installing..."

    # Detect package manager
    if command -v apt >/dev/null; then
        sudo apt update && sudo apt install -y git
    elif command -v yum >/dev/null; then
        sudo yum install -y git
    elif command -v dnf >/dev/null; then
        sudo dnf install -y git
    elif command -v zypper >/dev/null; then
        sudo zypper install -y git
    else
        echo " Unsupported package manager. Please install Git manually."
        exit 1
    fi
else
    echo "Git is already installed."
fi

echo " Installing Bats..."
bash installbats.sh

echo " Running functional tests..."
bats functional_test.bats

echo " Running unit tests..."
bats unit_test.bats

echo " All tests completed successfully!"


