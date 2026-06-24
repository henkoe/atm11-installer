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

# Parse latest version from CurseForge API
LATEST=$(curl -s "https://api.curseforge.com/v1/mods/916307/files?pageSize=50" \
    -H "Accept: application/json" 2>/dev/null | \
    grep -oP '"displayName":"ServerFiles-\K[\d.]+(?=\.zip)' | head -1 || echo "")

if [ -z "$LATEST" ]; then
    echo -e "${RED}✗${NC} Could not fetch latest version from CurseForge"
    exit 1
fi

echo -e "${GREEN}✓${NC} Latest available:    v$LATEST"
echo ""

if [ "$INSTALLED" = "$LATEST" ]; then
    echo -e "${GREEN}✓ You are up to date!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Update available!${NC}"
    echo ""
    echo "To update to v$LATEST, run:"
    echo "  ${BLUE}./update.sh${NC}"
    echo ""
    exit 1
fi
