#!/bin/sh
# RockNix installer — deploys cloud sync scripts alongside the built-in ones.
# RockNix already ships rclone at /usr/bin/rclone and has official cloud_backup.sh
# / cloud_restore.sh in /storage/.config/modules/. This installer deploys the
# universal scripts as an alternative, and can also install the hardened
# filter rules for the built-in scripts.
#
# Usage:
#   scp this file + scripts/*.sh to device, then run on device

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo .)"
REPO_SCRIPTS="$SCRIPT_DIR/../scripts"
[ ! -d "$REPO_SCRIPTS" ] && REPO_SCRIPTS="$SCRIPT_DIR/scripts"
[ ! -d "$REPO_SCRIPTS" ] && REPO_SCRIPTS="$(dirname "$0")/../scripts"

MODULES_DIR="/storage/.config/modules"
RCLONE_CONFIG="/storage/.config/rclone/rclone.conf"

echo "=== RockNix Cloud Sync Installer ==="

# Check we're on RockNix
if ! grep -qi "rocknix" /etc/os-release 2>/dev/null; then
    echo "ERROR: This doesn't look like a RockNix device"
    exit 1
fi

echo "rclone: $(/usr/bin/rclone version 2>/dev/null | head -1)"
echo "config: $RCLONE_CONFIG $([ -f "$RCLONE_CONFIG" ] && echo '(present)' || echo '(MISSING)')"
echo ""

# --- 1. Install universal scripts ---
echo "Step 1: universal cloud sync scripts"
mkdir -p "$MODULES_DIR"
for script in cloud_upload_saves.sh cloud_download_saves.sh; do
    src="$REPO_SCRIPTS/$script"
    [ ! -f "$src" ] && src="$SCRIPT_DIR/$script"
    [ ! -f "$src" ] && { echo "ERROR: $script not found"; exit 1; }
    cp "$src" "$MODULES_DIR/$script"
    chmod +x "$MODULES_DIR/$script"
    echo "  installed: $MODULES_DIR/$script"
done

# --- 2. Note about built-in scripts ---
echo ""
echo "Step 2: built-in RockNix scripts"
if [ -f "$MODULES_DIR/cloud_backup.sh" ]; then
    echo "  Built-in scripts already present at $MODULES_DIR/"
    echo "  These are the official ROCKNIX scripts — they work alongside the universal ones."
    echo "  The universal scripts use a simpler per-device folder naming scheme."
fi

echo ""
echo "=== Done! ==="
echo "Universal scripts: $MODULES_DIR/cloud_{upload,download}_saves.sh"
echo "Built-in scripts:  $MODULES_DIR/cloud_{backup,restore}.sh"
echo ""
echo "Run:"
echo "  $MODULES_DIR/cloud_upload_saves.sh    # universal upload"
echo "  $MODULES_DIR/cloud_download_saves.sh  # universal download"
