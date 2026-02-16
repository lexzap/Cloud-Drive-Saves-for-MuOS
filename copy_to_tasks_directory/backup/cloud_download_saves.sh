#!/bin/sh
# HELP: Download saves/screenshots from Cloud Drive
# ICON: Cloud_Download_Saves

. /opt/muos/script/var/func.sh

FRONTEND stop

LOGFILE="/tmp/tt_rclone_download.log"
LOGPIPE="/tmp/tt_rclone_download.pipe"
TEE_PID=""

start_logging() {
    : > "${LOGFILE}"
    if [ -p "${LOGPIPE}" ]; then
        rm -f "${LOGPIPE}"
    fi
    if mkfifo "${LOGPIPE}"; then
        tee -a "${LOGFILE}" < "${LOGPIPE}" &
        TEE_PID=$!
        exec > "${LOGPIPE}" 2>&1
    else
        exec >> "${LOGFILE}" 2>&1
    fi
}

# muOS Goose OS directory paths
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

cleanup() {
    sync
    echo "All Done!"
    TBOX sleep 2
    if [ -n "${TEE_PID}" ]; then
        kill "${TEE_PID}" >/dev/null 2>&1
        wait "${TEE_PID}" >/dev/null 2>&1
    fi
    if [ -n "${LOGPIPE}" ] && [ -p "${LOGPIPE}" ]; then
        rm -f "${LOGPIPE}"
    fi
    FRONTEND start task
}

fail() {
    echo "❌ ERROR: $1" >&2
    cleanup
    exit 1
}

start_logging

echo "Starting cloud download at $(date +"%Y-%m-%d %H:%M:%S")"

# (Goose OS: icon installation handled by task system)

# Check for rclone binary
if [ ! -f "${RCLONE_BINARY}" ]; then
    echo "   Please follow the setup guide to download and install the ARMv7 rclone binary"
    fail "rclone binary not found at ${RCLONE_BINARY}"
fi

# Check if rclone binary is executable
if [ ! -x "${RCLONE_BINARY}" ]; then
    fail "rclone binary is not executable (run: chmod +x ${RCLONE_BINARY})"
fi

# Check for rclone config file
if [ ! -f "${RCLONE_CONFIG}" ]; then
    echo "   Please copy your rclone.conf file from your computer to this location"
    fail "rclone config file not found at ${RCLONE_CONFIG}"
fi

# Auto-detect cloud remote from config file
echo "🔍 Detecting cloud service from config..."
CLOUD_REMOTE_NAME=$(grep -E '^\[(onedrive|gdrive|dropbox)\]' "${RCLONE_CONFIG}" | head -n 1 | sed 's/\[\(.*\)\]/\1/')
if [ -z "${CLOUD_REMOTE_NAME}" ]; then
    fail "No supported cloud remote found in rclone config"
fi
echo "   Found cloud remote: ${CLOUD_REMOTE_NAME}"

# Check target directories exist
if [ ! -d "${SAVE_DIR}" ]; then
    fail "Save directory not found at ${SAVE_DIR}"
fi

if [ ! -d "${SCREENSHOT_DIR}" ]; then
    fail "Screenshot directory not found at ${SCREENSHOT_DIR}"
fi

# Test internet connectivity
echo "🌐 Testing internet connectivity..."
if ! ${RCLONE_BINARY} version > /dev/null 2>&1; then
    fail "rclone command failed - check installation"
fi

# Test cloud service connectivity
echo "☁️  Testing cloud service connectivity..."
if ! ${RCLONE_BINARY} lsd ${CLOUD_REMOTE_NAME}: --config="${RCLONE_CONFIG}" > /dev/null 2>&1; then
    fail "Cannot connect to cloud service (${CLOUD_REMOTE_NAME})"
fi

echo "✅ All checks passed! Starting download..."

## TODO: fix how to display the info panel in muOS
# Display an info panel
#LD_PRELOAD=/run/muos/storage/lib/libpadsp.so /run/muos/storage/bin/infoPanel -t "Downloading Saves" -m "Your saves are being downloaded from Dropbox!" --auto &

# Synchronize saves (only download files that are newer on cloud than local)
echo "📥 Downloading save files (newer cloud files only)..."
echo "   📝 Note: Only files newer than local versions will be downloaded"
${RCLONE_BINARY} copy -P -L --no-check-certificate --update "${CLOUD_REMOTE_NAME}:${CLOUD_SAVE_PATH}/" "${SAVE_DIR}/" --config="${RCLONE_CONFIG}"
if [ $? -ne 0 ]; then
    fail "Download of save files failed"
fi

# Synchronize screenshots (only download files that are newer on cloud than local)
echo "📸 Downloading screenshots (newer cloud files only)..."
echo "   📝 Note: Only files newer than local versions will be downloaded"
${RCLONE_BINARY} copy -P -L --no-check-certificate --update "${CLOUD_REMOTE_NAME}:${CLOUD_SCREENSHOT_PATH}/" "${SCREENSHOT_DIR}/" --config="${RCLONE_CONFIG}"
if [ $? -ne 0 ]; then
    fail "Download of screenshots failed"
fi

echo ""
echo "✅ Download completed successfully!"
echo "   🛡️  Data protection: Only downloaded files that were newer than existing local versions"
echo "   📅 Timestamp-based sync prevents accidental overwrites"

echo "Sync Filesystem"
sync

echo "Download completed at $(date +"%Y-%m-%d %H:%M:%S")"
cleanup
exit 0


