#!/bin/sh
##################################################################################
## Script for MuOS Pixie to download all save, screenshots, and video recordings 
## folder contents to cloud drive
##################################################################################

echo "$0 $*"

##################################################################################
## Configuration Variables
##################################################################################

# muOS directory paths
MUOS_ROOT="/mnt/mmc/MUOS"
MUOS_USER_DATA="/run/muos/storage"

# Tool and config paths
RCLONE_BINARY="${MUOS_ROOT}/tools/rclone"
RCLONE_CONFIG="${MUOS_ROOT}/tools/rclone.conf"

# Target directories (where we're downloading to)
SAVE_DIR="${MUOS_USER_DATA}/save"
SCREENSHOT_DIR="${MUOS_USER_DATA}/screenshot"

# Cloud storage remote and paths
CLOUD_REMOTE_NAME=""  # Will be auto-detected from config
CLOUD_SAVE_PATH="/ambernic/saves"
CLOUD_SCREENSHOT_PATH="/ambernic/screenshot"

##################################################################################
## Pre-flight checks
##################################################################################

echo "=== muOS Cloud Download: Pre-flight Checks ==="
echo ""

# Check for rclone binary
if [ ! -f "${RCLONE_BINARY}" ]; then
    echo "❌ ERROR: rclone binary not found at ${RCLONE_BINARY}"
    echo "   Please follow the setup guide to download and install the ARMv7 rclone binary"
    exit 1
fi

# Check if rclone binary is executable
if [ ! -x "${RCLONE_BINARY}" ]; then
    echo "❌ ERROR: rclone binary is not executable"
    echo "   Run: chmod +x ${RCLONE_BINARY}"
    exit 1
fi

# Check for rclone config file
if [ ! -f "${RCLONE_CONFIG}" ]; then
    echo "❌ ERROR: rclone config file not found at ${RCLONE_CONFIG}"
    echo "   Please copy your rclone.conf file from your computer to this location"
    exit 1
fi

# Auto-detect cloud remote from config file
echo "🔍 Detecting cloud service from config..."
CLOUD_REMOTE_NAME=$(grep -E '^\[(onedrive|gdrive|dropbox)\]' "${RCLONE_CONFIG}" | head -n 1 | sed 's/\[\(.*\)\]/\1/')
if [ -z "${CLOUD_REMOTE_NAME}" ]; then
    echo "❌ ERROR: No supported cloud remote found in rclone config"
    echo "   Please ensure your rclone.conf contains a [dropbox], [gdrive], or [onedrive] section"
    echo "   Supported services: Dropbox, Google Drive, OneDrive"
    exit 1
fi
echo "   Found cloud remote: ${CLOUD_REMOTE_NAME}"

# Check target directories exist
if [ ! -d "${SAVE_DIR}" ]; then
    echo "❌ ERROR: Save directory not found at ${SAVE_DIR}"
    echo "   This directory should exist in muOS. Check your muOS installation."
    exit 1
fi

if [ ! -d "${SCREENSHOT_DIR}" ]; then
    echo "❌ ERROR: Screenshot directory not found at ${SCREENSHOT_DIR}"
    echo "   This directory should exist in muOS. Check your muOS installation."
    exit 1
fi

# Test internet connectivity
echo "🌐 Testing internet connectivity..."
if ! ${RCLONE_BINARY} version > /dev/null 2>&1; then
    echo "❌ ERROR: rclone command failed - check installation"
    exit 1
fi

# Test cloud service connectivity
echo "☁️  Testing cloud service connectivity..."
if ! ${RCLONE_BINARY} lsd ${CLOUD_REMOTE_NAME}: --config="${RCLONE_CONFIG}" > /dev/null 2>&1; then
    echo "❌ ERROR: Cannot connect to cloud service (${CLOUD_REMOTE_NAME})"
    echo "   Check your internet connection and rclone configuration"
    echo "   Make sure your device is connected to WiFi"
    exit 1
fi

echo "✅ All checks passed! Starting download..."
echo ""

##################################################################################
## Download operations
##################################################################################

## TODO: fix how to display the info panel in muOS
# Display an info panel
#LD_PRELOAD=/run/muos/storage/lib/libpadsp.so /run/muos/storage/bin/infoPanel -t "Downloading Saves" -m "Your saves are being downloaded from Dropbox!" --auto &

# Synchronize saves
echo "📥 Downloading save files..."
${RCLONE_BINARY} copy -P -L --no-check-certificate "${CLOUD_REMOTE_NAME}:${CLOUD_SAVE_PATH}/" "${SAVE_DIR}/" --config="${RCLONE_CONFIG}"

# Synchronize screenshots
echo "📸 Downloading screenshots..."
${RCLONE_BINARY} copy -P -L --no-check-certificate "${CLOUD_REMOTE_NAME}:${CLOUD_SCREENSHOT_PATH}/" "${SCREENSHOT_DIR}/" --config="${RCLONE_CONFIG}"

echo ""
echo "✅ Download completed successfully!"

