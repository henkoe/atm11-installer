#!/bin/bash

# ATM11 Server Installer for Linux + Crafty Controller
# Professional installer with version selection, Java checking, pretty UI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="${SERVER_DIR:-.}"
INTERACTIVE="${INTERACTIVE:-true}"
VERSION_SELECT="${1:-}"
QUIET="${QUIET:-false}"

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     ATM11 Server Installer             ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check Java version
check_java() {
    if ! command -v java &> /dev/null; then
        print_error "Java not found. Please install Java 21 or later."
        echo "  Ubuntu/Debian: sudo apt-get install openjdk-21-jre-headless"
        echo "  CentOS/RHEL:   sudo yum install java-21-openjdk-headless"
        exit 1
    fi

    JAVA_VERSION=$(java -version 2>&1 | grep -oP '(?<=version ").*?(?=")' | head -1)
    JAVA_MAJOR=$(echo "$JAVA_VERSION" | cut -d. -f1)

    if [ "$JAVA_MAJOR" -lt 21 ]; then
        print_error "Java 21 or later required (found Java $JAVA_MAJOR)"
        exit 1
    fi

    print_success "Java $JAVA_VERSION detected"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    local missing=0
    for cmd in curl unzip; do
        if ! command -v "$cmd" &> /dev/null; then
            print_error "$cmd is required but not installed"
            missing=$((missing + 1))
        fi
    done

    if [ $missing -gt 0 ]; then
        echo ""
        echo "Install missing tools:"
        echo "  Ubuntu/Debian: sudo apt-get install curl unzip"
        echo "  CentOS/RHEL:   sudo yum install curl unzip"
        exit 1
    fi

    print_success "All prerequisites found"
}

# Fetch available versions from CurseForge (with fallback)
# Returns format: "26.1.2|11-0.1.2" (serverfiles|modpack)
get_available_versions() {
    print_info "Fetching available versions from CurseForge..."

    # Try CurseForge API first (more reliable)
    # Extract both ServerFiles version and modpack version from displayName
    local versions=$(curl -s "https://api.curseforge.com/v1/mods/916307/files?pageSize=50" \
        -H "Accept: application/json" 2>/dev/null | \
        grep -oP '"displayName":"All the Mods 11-\K[\d.]+-ServerFiles-[\d.]+(?=\.zip)' | \
        awk -F'-ServerFiles-' '{print $2"|11-"$1}' | sort -rV | uniq || true)

    # Fallback: hardcoded recent versions if API fails (serverfiles|modpack)
    if [ -z "$versions" ]; then
        print_warning "Using cached version list (API unavailable)"
        versions="26.2.0|11-0.2.0
26.1.2|11-0.1.2
26.1.1|11-0.1.1
26.0.5|11-0.0.24
26.0.4|11-0.0.23"
    fi

    echo "$versions"
}

# Interactive version selection
# Input format: "26.1.2|11-0.1.2" (serverfiles|modpack)
select_version() {
    local versions=("$@")
    local count=${#versions[@]}

    if [ "$INTERACTIVE" != "true" ]; then
        echo "${versions[0]%|*}"  # Return only serverfiles version
        return
    fi

    echo ""
    print_info "Available ATM11 versions:"
    echo ""

    for i in "${!versions[@]}"; do
        local v=${versions[$i]}
        local server_ver="${v%|*}"     # ServerFiles version
        local modpack_ver="${v#*|}"    # Modpack version

        if [ $i -eq 0 ]; then
            echo "  $(($i + 1))) ServerFiles-$server_ver (Modpack $modpack_ver) ${YELLOW}(latest)${NC}"
        else
            echo "  $(($i + 1))) ServerFiles-$server_ver (Modpack $modpack_ver)"
        fi
    done

    echo ""
    read -p "Select version (default 1): " choice
    choice=${choice:-1}

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$count" ]; then
        print_error "Invalid selection"
        exit 1
    fi

    echo "${versions[$((choice - 1))]%|*}"  # Return only serverfiles version
}

# Download file with progress
download_file() {
    local url="$1"
    local output="$2"
    local filename=$(basename "$output")

    print_info "Downloading $filename..."
    curl -L "$url" -o "$output" --progress-bar 2>&1 || {
        print_error "Download failed"
        exit 1
    }
    print_success "Downloaded"
}

# Main installation flow
main() {
    print_header

    if [ "$QUIET" != "true" ]; then
        echo "Target directory: $SERVER_DIR"
        echo ""
    fi

    # Cleanup on exit
    cleanup() {
        [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
    }
    trap cleanup EXIT

    TEMP_DIR=$(mktemp -d)

    # Checks
    check_prerequisites
    check_java

    # Get versions
    mapfile -t available_versions < <(get_available_versions)
    [ ${#available_versions[@]} -eq 0 ] && {
        print_error "No versions found"
        exit 1
    }

    # Select version
    if [ -n "$VERSION_SELECT" ]; then
        selected_version="$VERSION_SELECT"
        print_info "Using specified version: $selected_version"
    else
        selected_version=$(select_version "${available_versions[@]}")
    fi

    print_success "Selected version: $selected_version"
    echo ""

    # Create server directory
    mkdir -p "$SERVER_DIR"

    # Download
    LATEST_FILE="ServerFiles-${selected_version}.zip"
    DOWNLOAD_LINK="https://www.curseforge.com/minecraft/modpacks/all-the-mods-11/download/$LATEST_FILE"
    download_file "$DOWNLOAD_LINK" "$TEMP_DIR/$LATEST_FILE"

    # Backup old files
    if [ -d "$SERVER_DIR/mods" ] || [ -d "$SERVER_DIR/config" ]; then
        BACKUP_DIR="$SERVER_DIR/backup-$(date +%s)"
        print_info "Backing up existing files..."
        mkdir -p "$BACKUP_DIR"
        [ -d "$SERVER_DIR/mods" ] && mv "$SERVER_DIR/mods" "$BACKUP_DIR/"
        [ -d "$SERVER_DIR/config" ] && mv "$SERVER_DIR/config" "$BACKUP_DIR/"
        print_success "Backed up to $BACKUP_DIR"
    fi

    # Extract
    print_info "Extracting server files..."
    unzip -q "$TEMP_DIR/$LATEST_FILE" -d "$SERVER_DIR"
    print_success "Extracted"

    # Setup server.properties
    if [ ! -f "$SERVER_DIR/server.properties" ]; then
        print_info "Creating server.properties..."
        cat > "$SERVER_DIR/server.properties" << 'EOF'
#Minecraft server properties
#Generated by ATM11 installer
server-port=25565
max-players=20
difficulty=2
gamemode=0
enable-command-block=false
spawn-protection=16
view-distance=10
enable-rcon=false
EOF
        print_success "Created server.properties"
    fi

    # Setup startup script
    print_info "Creating startup script..."
    cat > "$SERVER_DIR/start.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

# ATM11 Server Startup Script
# Adjust JVM args as needed for your system
JVM_ARGS="-Xmx6G -Xms6G -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

java $JVM_ARGS @user_jvm_args.txt @libraries/net/neoforged/neoforge/1.21.1-52.0.0.26/unix_args.txt nogui
EOF
    chmod +x "$SERVER_DIR/start.sh"
    print_success "Created start.sh"

    # Setup EULA
    echo "eula=true" > "$SERVER_DIR/eula.txt"
    print_success "EULA accepted"

    # Store version
    echo "$selected_version" > "$SERVER_DIR/version.txt"
    print_success "Version saved"

    # Summary
    echo ""
    print_header
    echo -e "${GREEN}Installation Complete!${NC}"
    echo ""
    echo "Server directory: $SERVER_DIR"
    echo "Installed version: $selected_version"
    echo ""
    echo "Next steps:"
    echo "  1. Review config: nano $SERVER_DIR/server.properties"
    echo "  2. Start server: $SERVER_DIR/start.sh"
    echo "  3. Add to Crafty Controller (if using)"
    echo ""
}

# For non-interactive/automation usage
if [ "$INTERACTIVE" = "false" ] && [ -z "$VERSION_SELECT" ]; then
    print_error "INTERACTIVE=false requires VERSION_SELECT to be set"
    echo "Example: INTERACTIVE=false VERSION_SELECT=26.1.2 ./install.sh"
    exit 1
fi

main
