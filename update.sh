#!/bin/bash

# ATM11 Server Updater
# Manually trigger updates for new versions

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="${SERVER_DIR:-.}"
VERSION_FILE="$SERVER_DIR/version.txt"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ATM11 Server Updater               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if [ ! -f "$SERVER_DIR/server.properties" ]; then
    echo -e "${RED}✗ No server.properties found in $SERVER_DIR${NC}"
    echo "Run install.sh first."
    exit 1
fi

# Check for available updates
if [ -f "$VERSION_FILE" ]; then
    INSTALLED=$(cat "$VERSION_FILE")
    echo -e "${GREEN}✓${NC} Currently installed: v$INSTALLED"
    echo ""

    echo -e "${BLUE}ℹ${NC} Checking CurseForge for latest version..."
    LATEST=$(curl -s "https://api.curseforge.com/v1/mods/916307/files?pageSize=50" \
        -H "Accept: application/json" 2>/dev/null | \
        grep -oP '"displayName":"ServerFiles-\K[\d.]+(?=\.zip)' | head -1 || echo "")

    echo -e "${GREEN}✓${NC} Latest available:    v$LATEST"
    echo ""

    if [ "$INSTALLED" = "$LATEST" ]; then
        echo -e "${GREEN}✓ Already on latest version${NC}"
        exit 0
    fi
fi

# Stop server gracefully
echo -e "${BLUE}ℹ${NC} Stopping server (if running)..."
if command -v systemctl &> /dev/null && systemctl is-active --quiet minecraft-atm11 2>/dev/null; then
    systemctl stop minecraft-atm11
    echo -e "${GREEN}✓${NC} Stopped via systemctl"
fi

echo ""

# Run installer in non-interactive mode with selected version
export INTERACTIVE=false
export SERVER_DIR="$SERVER_DIR"
bash "$SCRIPT_DIR/install.sh" "$LATEST"

echo ""
echo -e "${GREEN}✓ Update Complete!${NC}"
echo -e "${BLUE}ℹ${NC} Ready to restart server"
echo ""
