#!/bin/bash

# ATM11 Server Updater
# Manually trigger updates for new versions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="${SERVER_DIR:-.}"

echo "=== ATM11 Server Updater ==="
echo "Target directory: $SERVER_DIR"
echo ""

if [ ! -f "$SERVER_DIR/server.properties" ]; then
    echo "Error: No server.properties found in $SERVER_DIR"
    echo "Run install.sh first."
    exit 1
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
