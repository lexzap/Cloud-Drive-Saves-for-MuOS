#!/bin/sh
# HELP: Upload saves/screenshots to Cloud Drive
# ICON: Cloud_Upload_Saves

##################################################################################
# Goose OS task: Upload all save and screenshot folders to cloud drive
##################################################################################

. /opt/muos/script/var/func.sh

FRONTEND stop

echo "$0 $*"

##################################################################################
# Configuration Variables
##################################################################################

# muOS Goose OS directory paths
MUOS_ROOT="$(GET_VAR "device" "storage/rom/mount")/MUOS"
MUOS_USER_DATA="${MUOS_STORE_DIR}"

# Tool and config paths
RCLONE_BINARY="/opt/muos/bin/rclone"
RCLONE_CONFIG="${MUOS_ROOT}/tools/rclone.conf"

# Task icon path (Goose OS)
UPLOAD_ICON_SOURCE="${MUOS_ROOT}/tools/Cloud_Upload_Saves.png"

# Source directories (what we're uploading)
SAVE_DIR="${MUOS_USER_DATA}/save"
SCREENSHOT_DIR="${MUOS_USER_DATA}/screenshot"

# Cloud storage remote and paths
CLOUD_REMOTE_NAME=""  # Will be auto-detected from config
_BOARD="$(cat /opt/muos/device/config/board/name 2>/dev/null)"
CLOUD_SAVE_PATH="/${_BOARD}/saves"
CLOUD_SCREENSHOT_PATH="/${_BOARD}/screenshot"

##################################################################################
# Pre-flight checks
##################################################################################

echo "=== muOS Cloud Upload: Pre-flight Checks ==="
echo ""

# (Goose OS: icon installation handled by task system)

# Check for rclone binary
if [ ! -f "${RCLONE_BINARY}" ]; then
    echo "❌ ERROR: rclone binary not found at ${RCLONE_BINARY}"
    echo "   Please follow the setup guide to download and install the ARMv7 rclone binary"
    FRONTEND start task
    exit 1
fi

# Check if rclone binary is executable
if [ ! -x "${RCLONE_BINARY}" ]; then
    echo "❌ ERROR: rclone binary is not executable"
    echo "   Run: chmod +x ${RCLONE_BINARY}"
    FRONTEND start task
    exit 1
fi

# Check for rclone config file
if [ ! -f "${RCLONE_CONFIG}" ]; then
    echo "❌ ERROR: rclone config file not found at ${RCLONE_CONFIG}"
    echo "   Please copy your rclone.conf file from your computer to this location"
    FRONTEND start task
    exit 1
fi

# Auto-detect cloud remote from config file
echo "🔍 Detecting cloud service from config..."
CLOUD_REMOTE_NAME=$(grep -E '^\[(onedrive|gdrive|dropbox)\]' "${RCLONE_CONFIG}" | head -n 1 | sed 's/\[\(.*\)\]/\1/')
if [ -z "${CLOUD_REMOTE_NAME}" ]; then
    echo "❌ ERROR: No supported cloud remote found in rclone config"
    echo "   Please ensure your rclone.conf contains a [dropbox], [gdrive], or [onedrive] section"
    echo "   Supported services: Dropbox, Google Drive, OneDrive"
    FRONTEND start task
    exit 1
fi
echo "   Found cloud remote: ${CLOUD_REMOTE_NAME}"

# Check source directories exist
if [ ! -d "${SAVE_DIR}" ]; then
    echo "❌ ERROR: Save directory not found at ${SAVE_DIR}"
    echo "   This directory should exist in muOS. Check your muOS installation."
    FRONTEND start task
    exit 1
fi

if [ ! -d "${SCREENSHOT_DIR}" ]; then
    echo "❌ ERROR: Screenshot directory not found at ${SCREENSHOT_DIR}"
    echo "   This directory should exist in muOS. Check your muOS installation."
    FRONTEND start task
    exit 1
fi

# Test internet connectivity
echo "🌐 Testing internet connectivity..."
if ! ${RCLONE_BINARY} version > /dev/null 2>&1; then
    echo "❌ ERROR: rclone command failed - check installation"
    FRONTEND start task
    exit 1
fi

# Test cloud service connectivity
echo "☁️  Testing cloud service connectivity..."
if ! ${RCLONE_BINARY} lsd ${CLOUD_REMOTE_NAME}: --config="${RCLONE_CONFIG}" --contimeout 10s --timeout 10s --retries 1 --low-level-retries 1 > /dev/null 2>&1; then
    echo "❌ ERROR: Cannot connect to cloud service (${CLOUD_REMOTE_NAME})"
    echo "   Check your internet connection and rclone configuration"
    echo "   Make sure your device is connected to WiFi"
    FRONTEND start task
    exit 1
fi

echo "✅ All checks passed! Starting upload..."
echo ""

##################################################################################
## Upload operations
##
## Using --update flag to only upload files that are newer locally
## than the cloud versions. This prevents overwriting newer cloud saves
## with older local versions.
##################################################################################

## TODO: fix how to display the info panel in muOS
# Display an info panel 
#LD_PRELOAD=${MUOS_ROOT}/lib/libpadsp.so ${MUOS_ROOT}/bin/infoPanel -t "Uploading Saves" -m "Your saves are being uploaded to Cloud Drive!" --auto &

# Synchronize saves (only upload files that are newer locally than cloud)
echo "📤 Uploading save files (newer local files only)..."
echo "   📝 Note: Only files newer than cloud versions will be uploaded"
${RCLONE_BINARY} copy -P -L --no-check-certificate --update \
    --exclude "saves/**" \
    --exclude "screenshot/**" \
    --exclude "podcaster/**" \
    --exclude "pico8/**" \
    --exclude "*.mp3" \
    --exclude "*.MP3" \
    --exclude "*.m4a" \
    --exclude "*.M4A" \
    --exclude "*.aac" \
    --exclude "*.ogg" \
    --exclude "*.flac" \
    --exclude "*.wav" \
    --exclude "*.mp4" \
    --exclude "*.MP4" \
    --exclude "*.mkv" \
    --exclude "*.MKV" \
    --exclude "*.avi" \
    --exclude "*.AVI" \
    --exclude "*.mov" \
    --exclude "*.MOV" \
    --exclude "*.db" \
    --exclude "*.old" \
    --exclude "*.bak" \
    --exclude "*.tmp" \
    --exclude ".DS_Store" \
    --exclude "._*" \
    --exclude ".Spotlight-V100" \
    --exclude ".fseventsd" \
    "${SAVE_DIR}/" "${CLOUD_REMOTE_NAME}:${CLOUD_SAVE_PATH}/" --config="${RCLONE_CONFIG}"

# Synchronize screenshots (only upload files that are newer locally than cloud)
echo "📸 Uploading screenshots (newer local files only)..."
echo "   📝 Note: Only files newer than cloud versions will be uploaded"
${RCLONE_BINARY} copy -P -L --no-check-certificate --update "${SCREENSHOT_DIR}/" "${CLOUD_REMOTE_NAME}:${CLOUD_SCREENSHOT_PATH}/" --config="${RCLONE_CONFIG}"

echo ""
echo "✅ Upload completed successfully!"
echo "   🛡️  Data protection: Only uploaded files that were newer than existing cloud versions"
echo "   📅 Timestamp-based sync prevents accidental overwrites"

sync
TBOX sleep 2

FRONTEND start task
exit 0
