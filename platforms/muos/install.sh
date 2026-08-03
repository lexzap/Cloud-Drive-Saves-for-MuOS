#!/bin/sh
# MuOS installer — deploys universal cloud sync scripts to MuOS task locations.
# Works on MuOS Funky Jacaranda (2601.x) and later.
# Run this from the device itself, or push + execute via SSH.
#
# Usage:
#   scp this file + scripts/*.sh to device, then run on device
#   OR: ssh root@DEVICE 'sh /tmp/install.sh'

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo .)"
# When run from repo root, scripts are in ../scripts/
REPO_SCRIPTS="$SCRIPT_DIR/../scripts"
[ ! -d "$REPO_SCRIPTS" ] && REPO_SCRIPTS="$SCRIPT_DIR/scripts"
[ ! -d "$REPO_SCRIPTS" ] && REPO_SCRIPTS="$(dirname "$0")/../scripts"

MUOS_TASKS="/mnt/mmc/MUOS/tasks"
MUOS_TOOLS="/mnt/mmc/MUOS/Tools"

echo "=== MuOS Cloud Sync Installer ==="

# Check we're on MuOS
if [ ! -f /opt/muos/script/var/func.sh ]; then
    echo "ERROR: This doesn't look like a MuOS device (no /opt/muos/script/var/func.sh)"
    exit 1
fi

echo "Installing to $MUOS_TASKS/ ..."
mkdir -p "$MUOS_TASKS"

for script in cloud_upload_saves.sh cloud_download_saves.sh; do
    src="$REPO_SCRIPTS/$script"
    [ ! -f "$src" ] && src="$SCRIPT_DIR/$script"
    [ ! -f "$src" ] && { echo "ERROR: $script not found"; exit 1; }
    cp "$src" "$MUOS_TASKS/$script"
    chmod +x "$MUOS_TASKS/$script"
    echo "  installed: $MUOS_TASKS/$script"
done

# Also install to legacy Tools/ location (keep both in sync per MuOS convention)
echo ""
echo "Installing to $MUOS_TOOLS/ (legacy Tools menu) ..."
mkdir -p "$MUOS_TOOLS"

# Install with Title_Case names for the Tools menu
cp "$REPO_SCRIPTS/cloud_upload_saves.sh" "$MUOS_TOOLS/Cloud_Upload_Saves.sh"
cp "$REPO_SCRIPTS/cloud_download_saves.sh" "$MUOS_TOOLS/Cloud_Download_Saves.sh"
chmod +x "$MUOS_TOOLS/Cloud_Upload_Saves.sh" "$MUOS_TOOLS/Cloud_Download_Saves.sh"
echo "  installed: $MUOS_TOOLS/Cloud_Upload_Saves.sh"
echo "  installed: $MUOS_TOOLS/Cloud_Download_Saves.sh"

echo ""
echo "=== Done! ==="
echo "Tasks available in: Applications -> Task Toolkit -> Backup"
echo "Verify rclone config at: /mnt/mmc/MUOS/tools/rclone.conf"
