#!/bin/sh
# HELP: Upload saves/screenshots to Cloud Drive
# ICON: Cloud_Upload_Saves
#
# OS-agnostic cloud save sync — works on MuOS, Knulli (Batocera), and RockNix.
# Auto-detects the CFW at runtime and resolves all paths accordingly.
# Per-device cloud folder isolation: /<device-name>/saves/ and /<device-name>/screenshot/

# ============================================================================
# OS DETECTION
# ============================================================================
detect_os() {
    if [ -f /opt/muos/script/var/func.sh ]; then
        echo "muos"
    elif grep -qi "batocera" /etc/os-release 2>/dev/null; then
        echo "knulli"
    elif grep -qi "rocknix" /etc/os-release 2>/dev/null; then
        echo "rocknix"
    else
        echo "unknown"
    fi
}

OS="$(detect_os)"

# ============================================================================
# ENVIRONMENT SETUP — per-OS path resolution
# ============================================================================
setup_environment() {
    RCLONE_TIMEOUT_OPTS="--contimeout 10s --timeout 10s --retries 1 --low-level-retries 1"

    case "$OS" in
        muos)
            if [ -f /opt/muos/script/var/func.sh ]; then
                . /opt/muos/script/var/func.sh
            fi
            RCLONE_BINARY="/opt/muos/bin/rclone"
            [ ! -x "$RCLONE_BINARY" ] && RCLONE_BINARY="/mnt/mmc/MUOS/tools/rclone"
            RCLONE_CONFIG="/mnt/mmc/MUOS/tools/rclone.conf"
            SAVE_DIR="/run/muos/storage/save"
            SCREENSHOT_DIR="/run/muos/storage/screenshot"
            SAVEFILE_DIR=""
            DEVICE_NAME="$(cat /opt/muos/device/config/board/name 2>/dev/null)"
            [ -z "$DEVICE_NAME" ] && DEVICE_NAME="$(hostname 2>/dev/null || echo device)"
            ;;
        knulli)
            RCLONE_BINARY=""
            for p in /userdata/system/bin/rclone /usr/bin/rclone /usr/local/bin/rclone; do
                [ -x "$p" ] && RCLONE_BINARY="$p" && break
            done
            RCLONE_CONFIG=""
            for p in /userdata/system/configs/rclone/rclone.conf /storage/.config/rclone/rclone.conf; do
                [ -f "$p" ] && RCLONE_CONFIG="$p" && break
            done
            SAVE_DIR="/userdata/saves"
            SCREENSHOT_DIR="/userdata/screenshots"
            SAVEFILE_DIR=""
            DEVICE_NAME=""
            for f in /userdata/system/configs/cloud-sync.conf; do
                [ -f "$f" ] && DEVICE_NAME="$(grep '^DEVICE_NAME=' "$f" 2>/dev/null | cut -d= -f2-)" && break
            done
            [ -z "$DEVICE_NAME" ] && DEVICE_NAME="$(cat /proc/device-tree/model 2>/dev/null | tr -d '\0' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | head -c 30)"
            [ -z "$DEVICE_NAME" ] && DEVICE_NAME="$(hostname 2>/dev/null || echo knulli)"
            ;;
        rocknix)
            RCLONE_BINARY="/usr/bin/rclone"
            [ ! -x "$RCLONE_BINARY" ] && RCLONE_BINARY="$(which rclone 2>/dev/null)"
            RCLONE_CONFIG="/storage/.config/rclone/rclone.conf"
            SAVE_DIR="/storage/roms/savestates"
            SAVEFILE_DIR="/storage/roms/savefiles"
            SCREENSHOT_DIR="/storage/roms/screenshots"
            DEVICE_NAME="$(hostname 2>/dev/null || echo rocknix)"
            ;;
        *)
            # Generic fallback — try to find rclone and saves
            RCLONE_BINARY="$(which rclone 2>/dev/null)"
            RCLONE_CONFIG="$(dirname "$(find / -name rclone.conf -maxdepth 5 2>/dev/null | head -1)")/rclone.conf"
            SAVE_DIR="${HOME}/saves"
            SCREENSHOT_DIR="${HOME}/screenshots"
            SAVEFILE_DIR=""
            DEVICE_NAME="$(hostname 2>/dev/null || echo device)"
            ;;
    esac

    CLOUD_SAVE_PATH="/${DEVICE_NAME}/saves"
    CLOUD_SCREENSHOT_PATH="/${DEVICE_NAME}/screenshot"
}

# ============================================================================
# FRONTEND HELPERS — MuOS-specific, no-ops elsewhere
# ============================================================================
frontend_stop() {
    [ "$OS" = "muos" ] && FRONTEND stop 2>/dev/null
}

frontend_start() {
    [ "$OS" = "muos" ] && FRONTEND start task 2>/dev/null
}

tbox_sleep() {
    if [ "$OS" = "muos" ]; then
        TBOX sleep "$1" 2>/dev/null || sleep "$1"
    else
        sleep "$1"
    fi
}

# ============================================================================
# LOGGING
# ============================================================================
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/tmp/cloud_sync_${SCRIPT_NAME%.sh}.log"
LOG_PIPE="/tmp/cloud_sync_${SCRIPT_NAME%.sh}.pipe"
TEE_PID=""

start_logging() {
    : > "$LOG_FILE"
    [ -p "$LOG_PIPE" ] && rm -f "$LOG_PIPE"
    if mkfifo "$LOG_PIPE" 2>/dev/null; then
        tee -a "$LOG_FILE" < "$LOG_PIPE" &
        TEE_PID=$!
        exec > "$LOG_PIPE" 2>&1
    else
        exec >> "$LOG_FILE" 2>&1
    fi
}

log() {
    printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$1"
}

cleanup() {
    sync
    echo ""
    echo "All Done!"
    tbox_sleep 2
    [ -n "$TEE_PID" ] && kill "$TEE_PID" >/dev/null 2>&1 && wait "$TEE_PID" >/dev/null 2>&1
    [ -p "$LOG_PIPE" ] && rm -f "$LOG_PIPE"
    frontend_start
}

fail() {
    echo "ERROR: $1" >&2
    cleanup
    exit 1
}

# ============================================================================
# SHARED RCLONE EXCLUDES — inlined per busybox word-splitting safety
# (busybox sh mangles multi-line variables; inline flags are reliable)
# ============================================================================
RCLONE_EXCLUDES='--exclude saves/** --exclude screenshot/** --exclude podcaster/** --exclude pico8/** --exclude *.mp3 --exclude *.MP3 --exclude *.m4a --exclude *.M4A --exclude *.aac --exclude *.ogg --exclude *.flac --exclude *.wav --exclude *.mp4 --exclude *.MP4 --exclude *.mkv --exclude *.MKV --exclude *.avi --exclude *.AVI --exclude *.mov --exclude *.MOV --exclude *.db --exclude *.old --exclude *.bak --exclude *.tmp --exclude .DS_Store --exclude ._** --exclude .Spotlight-V100 --exclude .fseventsd'

# ============================================================================
# MAIN
# ============================================================================
setup_environment
frontend_stop
start_logging

echo "========================================"
echo "  Cloud Upload — $OS ($DEVICE_NAME)"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
echo ""

# Validate prerequisites
[ -z "$RCLONE_BINARY" ] && fail "rclone binary not found — install rclone first"
[ ! -f "$RCLONE_BINARY" ] && fail "rclone binary not found: $RCLONE_BINARY"
[ ! -x "$RCLONE_BINARY" ] && fail "rclone binary not executable: $RCLONE_BINARY"
[ ! -f "$RCLONE_CONFIG" ] && fail "rclone config not found: $RCLONE_CONFIG"
[ ! -d "$SAVE_DIR" ] && fail "Save directory not found: $SAVE_DIR"

echo "rclone: $RCLONE_BINARY"
echo "config: $RCLONE_CONFIG"
echo "saves:  $SAVE_DIR"
[ -n "$SAVEFILE_DIR" ] && [ -d "$SAVEFILE_DIR" ] && echo "files:  $SAVEFILE_DIR"
echo "shots:  $SCREENSHOT_DIR"
echo "cloud:  $CLOUD_SAVE_PATH"
echo ""

# Detect cloud remote
echo "Detecting cloud service..."
CLOUD_REMOTE_NAME=$(grep -E '^\[(onedrive|gdrive|dropbox|cloud)\]' "$RCLONE_CONFIG" 2>/dev/null | head -n 1 | sed 's/\[\(.*\)\]/\1/')
[ -z "$CLOUD_REMOTE_NAME" ] && fail "No cloud remote found in rclone config (expected [onedrive], [gdrive], [dropbox], or [cloud])"
echo "  Remote: $CLOUD_REMOTE_NAME"

# Test connectivity
echo "Testing connectivity..."
$RCLONE_BINARY lsd "${CLOUD_REMOTE_NAME}:" --config="$RCLONE_CONFIG" $RCLONE_TIMEOUT_OPTS > /dev/null 2>&1 \
    || fail "Cannot reach cloud service"

echo ""
echo "Uploading save files to ${CLOUD_SAVE_PATH}/..."
echo "  Excluded: legacy dirs, media, app data, macOS junk, temp files"
# shellcheck disable=SC2086
$RCLONE_BINARY copy -P -L --no-check-certificate --update \
    $RCLONE_EXCLUDES \
    "$SAVE_DIR/" "${CLOUD_REMOTE_NAME}:${CLOUD_SAVE_PATH}/" \
    --config="$RCLONE_CONFIG" || fail "Save upload failed"

# RockNix has separate savefiles dir — sync it too
if [ -n "$SAVEFILE_DIR" ] && [ -d "$SAVEFILE_DIR" ]; then
    echo "Uploading in-game save files from ${SAVEFILE_DIR}/..."
    # shellcheck disable=SC2086
    $RCLONE_BINARY copy -P -L --no-check-certificate --update \
        $RCLONE_EXCLUDES \
        "$SAVEFILE_DIR/" "${CLOUD_REMOTE_NAME}:${CLOUD_SAVE_PATH}/savefiles/" \
        --config="$RCLONE_CONFIG" || fail "Savefile upload failed"
fi

# Screenshots (if dir exists)
if [ -d "$SCREENSHOT_DIR" ]; then
    echo "Uploading screenshots to ${CLOUD_SCREENSHOT_PATH}/..."
    $RCLONE_BINARY copy -P -L --no-check-certificate --update \
        "$SCREENSHOT_DIR/" "${CLOUD_REMOTE_NAME}:${CLOUD_SCREENSHOT_PATH}/" \
        --config="$RCLONE_CONFIG" || fail "Screenshot upload failed"
fi

echo ""
echo "Upload complete at $(date '+%Y-%m-%d %H:%M:%S')"
sync
cleanup
exit 0
