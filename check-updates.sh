#!/bin/bash

# ATM11 Update Checker
# Shows currently installed version and available updates

set -e

SERVER_DIR="${SERVER_DIR:-.}"
VERSION_FILE="$SERVER_DIR/version.txt"

echo "=== ATM11 Update Checker ==="
echo ""

# Show installed version
if [ -f "$VERSION_FILE" ]; then
    INSTALLED=$(cat "$VERSION_FILE")
    echo "Currently installed: v$INSTALLED"
else
    echo "No version file found - server may not be installed yet"
    echo "Run ./install.sh first"
    exit 1
fi

echo ""
echo "Checking CurseForge for latest version..."

# Parse latest version from CurseForge
LATEST=$(curl -s "https://www.curseforge.com/minecraft/modpacks/all-the-mods-11/files" | \
    grep -oP 'ServerFiles-\K[\d.]+(?=\.zip)' | head -1)

if [ -z "$LATEST" ]; then
    echo "Error: Could not fetch latest version from CurseForge"
    exit 1
fi

echo "Latest available:    v$LATEST"
echo ""

if [ "$INSTALLED" = "$LATEST" ]; then
    echo "✓ You are up to date!"
    exit 0
else
    echo "⚠ Update available!"
    echo ""
    echo "To update to v$LATEST, run:"
    echo "  ./update.sh"
    echo ""
    exit 1
fi
