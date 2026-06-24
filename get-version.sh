#!/bin/bash

# Get currently installed ATM11 version on this system

SERVER_DIR="${SERVER_DIR:-.}"
VERSION_FILE="$SERVER_DIR/version.txt"

if [ ! -f "$VERSION_FILE" ]; then
    echo "Error: version.txt not found in $SERVER_DIR"
    echo "Server may not be installed yet."
    exit 1
fi

VERSION=$(cat "$VERSION_FILE")
echo "Installed ATM11 version: v$VERSION"
