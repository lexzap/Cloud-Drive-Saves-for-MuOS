#!/bin/sh
##################################################################################
## Script for MuOS Pixie to download all save, screenshots, and video recordings 
## folder contents to cloud drive
##################################################################################

#!/bin/sh
echo "$0 $*"

# Display an info panel
#LD_PRELOAD=/run/muos/storage/lib/libpadsp.so /run/muos/storage/bin/infoPanel -t "Downloading Saves" -m "Your saves are being downloaded from Dropbox!" --auto &

# Synchronize saves
/mnt/mmc/MUOS/tools/rclone copy -P -L --no-check-certificate dropbox:/ambernic/saves/ /run/muos/storage/save/ --config=/run/muos/storage/tools/rclone.conf

# Synchronize screenshots
/mnt/mmc/MUOS/tools/rclone copy -P -L --no-check-certificate dropbox:/ambernic/screenshot/ /run/muos/storage/screenshot/ --config=/run/muos/storage/tools/rclone.conf

