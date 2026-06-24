#!/bin/bash

# ATM11 Server Updater
# Manually trigger updates for new versions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="${SERVER_DIR:-.}"
VERSION_FILE="$SERVER_DIR/version.txt"

echo "=== ATM11 Server Updater ==="
echo "Target directory: $SERVER_DIR"
echo ""

if [ ! -f "$SERVER_DIR/server.properties" ]; then
    echo "Error: No server.properties found in $SERVER_DIR"
    echo "Run install.sh first."
    exit 1
fi

# Check for available updates first
if [ -f "$VERSION_FILE" ]; then
    INSTALLED=$(cat "$VERSION_FILE")
    echo "Currently installed: v$INSTALLED"
    echo ""

    LATEST=$(curl -s "https://www.curseforge.com/minecraft/modpacks/all-the-mods-11/files" | \
        grep -oP 'ServerFiles-\K[\d.]+(?=\.zip)' | head -1)

    if [ "$INSTALLED" = "$LATEST" ]; then
        echo "✓ Already on latest version (v$LATEST)"
        exit 0
    else
        echo "Latest available:    v$LATEST"
        echo "Proceeding with update..."
    fi
    echo ""
fi

echo "Stopping server (if running)..."
if command -v systemctl &> /dev/null && systemctl is-active --quiet minecraft-atm11; then
    systemctl stop minecraft-atm11
    echo "Stopped via systemctl"
fi

# Use install.sh with the SERVER_DIR already set
export SERVER_DIR="$SERVER_DIR"
bash "$SCRIPT_DIR/install.sh"

echo ""
echo "=== Update Complete ==="
echo "Ready to restart server"
echo ""
