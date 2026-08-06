#!/bin/sh
# HELP: Upload saves/screenshots to Cloud Drive
# ICON: Cloud_Upload_Saves

. /opt/muos/script/var/func.sh

FRONTEND stop

LOGFILE="/tmp/tt_rclone_upload.log"
LOGPIPE="/tmp/tt_rclone_upload.pipe"
TEE_PID=""

start_logging() {
    : > "${LOGFILE}"
    if [ -p "${LOGPIPE}" ]; then rm -f "${LOGPIPE}"; fi
    if mkfifo "${LOGPIPE}"; then
        tee -a "${LOGFILE}" < "${LOGPIPE}" &
        TEE_PID=$!
        exec > "${LOGPIPE}" 2>&1
    else
        exec >> "${LOGFILE}" 2>&1
    fi
}

MUOS_ROOT="/mnt/mmc/MUOS"
MUOS_USER_DATA="/run/muos/storage"
RCLONE_BINARY="/opt/muos/bin/rclone"
[ ! -x "${RCLONE_BINARY}" ] && RCLONE_BINARY="${MUOS_ROOT}/tools/rclone"
RCLONE_CONFIG="${MUOS_ROOT}/tools/rclone.conf"
SAVE_DIR="${MUOS_USER_DATA}/save"
SCREENSHOT_DIR="${MUOS_USER_DATA}/screenshot"
_BOARD="$(cat /opt/muos/device/config/board/name 2>/dev/null)"
CLOUD_SAVE_PATH="/${_BOARD}/saves"
CLOUD_SCREENSHOT_PATH="/${_BOARD}/screenshot"

cleanup() {
    sync
    echo "All Done!"
    TBOX sleep 2
    [ -n "${TEE_PID}" ] && kill "${TEE_PID}" >/dev/null 2>&1 && wait "${TEE_PID}" >/dev/null 2>&1
    [ -p "${LOGPIPE}" ] && rm -f "${LOGPIPE}"
    FRONTEND start task
}
fail() { echo "ERROR: $1" >&2; cleanup; exit 1; }

start_logging
echo "Cloud upload started at $(date +"%Y-%m-%d %H:%M:%S")"

[ ! -f "${RCLONE_BINARY}" ] && fail "rclone binary not found: ${RCLONE_BINARY}"
[ ! -x "${RCLONE_BINARY}" ] && fail "rclone binary not executable"
[ ! -f "${RCLONE_CONFIG}" ] && fail "rclone config not found: ${RCLONE_CONFIG}"
[ ! -d "${SAVE_DIR}" ]       && fail "Save directory not found: ${SAVE_DIR}"
[ ! -d "${SCREENSHOT_DIR}" ] && fail "Screenshot directory not found: ${SCREENSHOT_DIR}"

echo "Detecting cloud service..."
CLOUD_REMOTE_NAME=$(grep -E '^\[(onedrive|gdrive|dropbox)\]' "${RCLONE_CONFIG}" | head -n 1 | sed 's/\[\(.*\)\]/\1/')
[ -z "${CLOUD_REMOTE_NAME}" ] && fail "No cloud remote found in rclone config"
echo "   Remote: ${CLOUD_REMOTE_NAME}"

echo "Testing connectivity..."
${RCLONE_BINARY} lsd ${CLOUD_REMOTE_NAME}: --config="${RCLONE_CONFIG}" --contimeout 10s --timeout 10s --retries 1 --low-level-retries 1 > /dev/null 2>&1 \
    || fail "Cannot reach cloud service"

echo ""
echo "Uploading save files..."
echo "   Excluded: legacy dirs, media files, app data, macOS junk, temp files"
echo "   Included: all emulator battery saves (.srm .sav .dsv .rtc .mpk etc), state files, Dreamcast VMU (.bin)"
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
    "${SAVE_DIR}/" "${CLOUD_REMOTE_NAME}:${CLOUD_SAVE_PATH}/" \
    --config="${RCLONE_CONFIG}" || fail "Save upload failed"

echo "Uploading screenshots..."
${RCLONE_BINARY} copy -P -L --no-check-certificate --update \
    "${SCREENSHOT_DIR}/" "${CLOUD_REMOTE_NAME}:${CLOUD_SCREENSHOT_PATH}/" \
    --config="${RCLONE_CONFIG}" || fail "Screenshot upload failed"

echo ""
echo "Upload complete at $(date +"%Y-%m-%d %H:%M:%S")"
sync
cleanup
exit 0
