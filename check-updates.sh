#!/bin/bash

# ATM11 Update Checker
# Shows currently installed version and available updates

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SERVER_DIR="${SERVER_DIR:-.}"
VERSION_FILE="$SERVER_DIR/version.txt"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ATM11 Update Checker               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Show installed version
if [ -f "$VERSION_FILE" ]; then
    INSTALLED=$(cat "$VERSION_FILE")
    echo -e "${GREEN}✓${NC} Currently installed: v$INSTALLED"
else
    echo -e "${RED}✗${NC} No version file found - server may not be installed yet"
    echo "Run ./install.sh first"
    exit 1
fi

echo ""
echo -e "${BLUE}ℹ${NC} Checking CurseForge for latest version..."

# Parse latest versions from CurseForge API
# Gets both ServerFiles and modpack versions
LATEST_DATA=$(curl -s "https://api.curseforge.com/v1/mods/916307/files?pageSize=50" \
    -H "Accept: application/json" 2>/dev/null | \
    grep -oP '"displayName":"All the Mods 11-\K[\d.]+-ServerFiles-[\d.]+(?=\.zip)' | head -1 || echo "")

if [ -z "$LATEST_DATA" ]; then
    LATEST=""
else
    LATEST=$(echo "$LATEST_DATA" | awk -F'-ServerFiles-' '{print $2}')
    MODPACK_LATEST=$(echo "$LATEST_DATA" | awk -F'-ServerFiles-' '{print $1}')
fi

if [ -z "$LATEST" ]; then
    echo -e "${RED}✗${NC} Could not fetch latest version from CurseForge"
    exit 1
fi

echo -e "${GREEN}✓${NC} Latest ServerFiles:  v$LATEST"
[ -n "$MODPACK_LATEST" ] && echo -e "${GREEN}✓${NC} Latest Modpack:      v11-$MODPACK_LATEST"
echo ""

if [ "$INSTALLED" = "$LATEST" ]; then
    echo -e "${GREEN}✓ You are up to date!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Update available!${NC}"
    [ -n "$MODPACK_LATEST" ] && echo "ServerFiles v$LATEST (Modpack 11-$MODPACK_LATEST)"
    echo ""
    echo "To update, run:"
    echo "  ${BLUE}./update.sh${NC}"
    echo ""
    exit 1
fi
