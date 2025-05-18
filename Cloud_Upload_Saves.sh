#!/bin/sh
##################################################################################
## Script for MuOS Pixie to upload all save, screenshots, and video recordings 
## folder contents to cloud drive
##################################################################################

echo "$0 $*"

# Display an info panel
#LD_PRELOAD=/mnt/mmc/MUOS/lib/libpadsp.so /mnt/mmc/MUOS/bin/infoPanel -t "Uploading Saves" -m "Your saves are being uploaded to Cloud Drive!" --auto &

# Synchronize saves
/mnt/mmc/MUOS/tools/rclone copy -P -L --no-check-certificate /run/muos/storage/save/ dropbox:/ambernic/saves/ --config=/mnt/mmc/MUOS/tools/rclone.conf

# Synchronize screenshots
/mnt/mmc/MUOS/tools/rclone copy -P -L --no-check-certificate /run/muos/storage/screenshot/ dropbox:/ambernic/screenshot/ --config=/mnt/mmc/MUOS/tools/rclone.conf
