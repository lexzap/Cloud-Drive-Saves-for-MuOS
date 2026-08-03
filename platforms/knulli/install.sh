#!/bin/sh
# Knulli (Batocera-family) installer — deploys rclone binary + cloud sync scripts.
# Tested on Knulli Scarab (Batocera 42, Anbernic RG40XXH).
# rclone is NOT pre-installed on Knulli — this installer fetches the arm64 binary.
#
# Prerequisites:
#   - Device must be online (WiFi connected)
#   - Run as root (default on Knulli)
#
# Usage:
#   scp this file + scripts/*.sh + rclone.conf to device, then run on device
#   OR: push everything via SSH and execute

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo .)"
REPO_SCRIPTS="$SCRIPT_DIR/../scripts"
[ ! -d "$REPO_SCRIPTS" ] && REPO_SCRIPTS="$SCRIPT_DIR/scripts"
[ ! -d "$REPO_SCRIPTS" ] && REPO_SCRIPTS="$(dirname "$0")/../scripts"

RCLONE_BIN_DIR="/userdata/system/bin"
RCLONE_CONF_DIR="/userdata/system/configs/rclone"
SCRIPTS_DIR="/userdata/system/scripts"
CONFIGS_DIR="/userdata/system/configs"

# Default device name — override by editing cloud-sync.conf after install
DEFAULT_DEVICE_NAME="rg40xx-h"

echo "=== Knulli Cloud Sync Installer ==="

# Check we're on Knulli/Batocera
if ! grep -qi "batocera" /etc/os-release 2>/dev/null; then
    echo "ERROR: This doesn't look like a Knulli/Batocera device"
    exit 1
fi

# --- 1. Install rclone binary if missing ---
echo ""
echo "Step 1: rclone binary"
if [ -x "$RCLONE_BIN_DIR/rclone" ]; then
    echo "  Already installed: $($RCLONE_BIN_DIR/rclone version 2>/dev/null | head -1)"
else
    mkdir -p "$RCLONE_BIN_DIR"
    echo "  Downloading rclone arm64..."
    RCLONE_URL="https://downloads.rclone.org/rclone-current-linux-arm64.zip"
    TMP_DIR="/tmp/rclone_install_$$"
    mkdir -p "$TMP_DIR"
    if curl -sL "$RCLONE_URL" -o "$TMP_DIR/rclone.zip" 2>/dev/null || \
       wget -q "$RCLONE_URL" -O "$TMP_DIR/rclone.zip" 2>/dev/null; then
        cd "$TMP_DIR"
        unzip -q rclone.zip 2>/dev/null || python3 -c "import zipfile; zipfile.ZipFile('rclone.zip').extractall()" 2>/dev/null
        RCLONE_EXTRACTED=$(find . -name rclone -type f -path "*/linux-arm64/*" | head -1)
        [ -z "$RCLONE_EXTRACTED" ] && RCLONE_EXTRACTED=$(find . -name rclone -type f | head -1)
        if [ -n "$RCLONE_EXTRACTED" ] && [ -f "$RCLONE_EXTRACTED" ]; then
            cp "$RCLONE_EXTRACTED" "$RCLONE_BIN_DIR/rclone"
            chmod +x "$RCLONE_BIN_DIR/rclone"
            echo "  Installed: $($RCLONE_BIN_DIR/rclone version 2>/dev/null | head -1)"
        else
            echo "  WARNING: Could not extract rclone from zip. Install manually."
        fi
        cd /
        rm -rf "$TMP_DIR"
    else
        echo "  WARNING: Could not download rclone. Install manually from https://rclone.org/downloads/"
    fi
fi

# --- 2. Install rclone config ---
echo ""
echo "Step 2: rclone configuration"
mkdir -p "$RCLONE_CONF_DIR"
if [ -f "$SCRIPT_DIR/rclone.conf" ] || [ -f "$SCRIPT_DIR/../rclone.conf" ]; then
    SRC_CONF="$SCRIPT_DIR/rclone.conf"
    [ ! -f "$SRC_CONF" ] && SRC_CONF="$SCRIPT_DIR/../rclone.conf"
    cp "$SRC_CONF" "$RCLONE_CONF_DIR/rclone.conf"
    chmod 600 "$RCLONE_CONF_DIR/rclone.conf"
    echo "  Installed: $RCLONE_CONF_DIR/rclone.conf"
elif [ ! -f "$RCLONE_CONF_DIR/rclone.conf" ]; then
    echo "  WARNING: No rclone.conf provided. Configure with:"
    echo "    $RCLONE_BIN_DIR/rclone config --config=$RCLONE_CONF_DIR/rclone.conf"
fi

# --- 3. Install cloud sync scripts ---
echo ""
echo "Step 3: cloud sync scripts"
mkdir -p "$SCRIPTS_DIR"
for script in cloud_upload_saves.sh cloud_download_saves.sh; do
    src="$REPO_SCRIPTS/$script"
    [ ! -f "$src" ] && src="$SCRIPT_DIR/$script"
    [ ! -f "$src" ] && { echo "ERROR: $script not found"; exit 1; }
    cp "$src" "$SCRIPTS_DIR/$script"
    chmod +x "$SCRIPTS_DIR/$script"
    echo "  installed: $SCRIPTS_DIR/$script"
done

# --- 4. Device name config ---
echo ""
echo "Step 4: device name configuration"
mkdir -p "$CONFIGS_DIR"
CONF_FILE="$CONFIGS_DIR/cloud-sync.conf"
if [ ! -f "$CONF_FILE" ]; then
    echo "DEVICE_NAME=$DEFAULT_DEVICE_NAME" > "$CONF_FILE"
    echo "  Created: $CONF_FILE (DEVICE_NAME=$DEFAULT_DEVICE_NAME)"
    echo "  Edit this file to change the cloud folder name."
else
    echo "  Existing: $CONF_FILE"
    echo "  DEVICE_NAME=$(grep DEVICE_NAME "$CONF_FILE" 2>/dev/null | cut -d= -f2-)"
fi

# --- 5. Ensure save/screenshot dirs exist ---
mkdir -p /userdata/saves /userdata/screenshots

echo ""
echo "=== Done! ==="
echo "Cloud sync scripts: $SCRIPTS_DIR/"
echo "rclone binary:       $RCLONE_BIN_DIR/rclone"
echo "rclone config:       $RCLONE_CONF_DIR/rclone.conf"
echo "device name:         $CONFIGS_DIR/cloud-sync.conf"
echo ""
echo "Run:" 
echo "  $SCRIPTS_DIR/cloud_upload_saves.sh    # upload saves to cloud"
echo "  $SCRIPTS_DIR/cloud_download_saves.sh  # download saves from cloud"
echo ""
echo "To add to EmulationStation menu, see: platforms/knulli/es_entry_readme.md"
