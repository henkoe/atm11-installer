#!/bin/bash

# Get currently installed ATM11 version on this system

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

SERVER_DIR="${SERVER_DIR:-.}"
VERSION_FILE="$SERVER_DIR/version.txt"

if [ ! -f "$VERSION_FILE" ]; then
    echo -e "${RED}✗${NC} Error: version.txt not found in $SERVER_DIR"
    echo "Server may not be installed yet."
    exit 1
fi

VERSION=$(cat "$VERSION_FILE")
echo -e "${GREEN}✓${NC} Installed ATM11 version: v$VERSION"
