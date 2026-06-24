#!/bin/bash

# ATM11 Server Installer - Simple wrapper
# Provides convenient one-liner installation with defaults

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="${1:-.}"

export INTERACTIVE=true
bash "$SCRIPT_DIR/install.sh"
