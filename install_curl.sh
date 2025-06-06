#!/bin/bash

# Define temporary directory variable with timestamp for uniqueness
INSTALLER_TEMP_DIR="/tmp/zalo_curl_$(date +%s)"

# Clean up any existing temp directory if it exists
if [ -d "$INSTALLER_TEMP_DIR" ]; then
    rm -rf "$INSTALLER_TEMP_DIR"
fi

# Create new temp directory
mkdir -p "$INSTALLER_TEMP_DIR" || {
    echo "Failed to create temporary directory $INSTALLER_TEMP_DIR" >&2
    exit 1
}

# Clone repository
git clone https://github.com/cobaohieu/zalo-linux-unofficial "$INSTALLER_TEMP_DIR" || {
    echo "Failed to clone repository" >&2
    exit 1
}

# Change to temp directory
cd "$INSTALLER_TEMP_DIR" || {
    echo "Failed to enter directory $INSTALLER_TEMP_DIR" >&2
    exit 1
}

# Make install script executable and run it
chmod +x install.sh
./install.sh

# Clean up (optional - remove if you want to keep the files for debugging)
# rm -rf "$INSTALLER_TEMP_DIR"