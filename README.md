# Cloud Drive Saves for Handhelds

*OS-agnostic cloud sync for save files and screenshots on retro handheld devices*

---

## Overview

Universal cloud synchronization for save files and screenshots across multiple
Linux CFWs (custom firmwares) for retro handheld devices. One set of scripts,
auto-detecting your CFW at runtime — no per-device forks.

### Supported CFWs

| CFW | Device | rclone | Saves path | Cloud folder |
|-----|--------|--------|------------|--------------|
| **MuOS** (Funky Jacaranda) | TrimUI Brick, Anbernic RG40XXH, etc. | Pre-installed | `/run/muos/storage/save` | `/<board-name>/saves` |
| **Knulli** (Batocera 42) | Anbernic RG40XXH Scarab | Auto-installed | `/userdata/saves` | `/<device-name>/saves` |
| **RockNix** | MiniLoong Pocket 1, etc. | Pre-installed | `/storage/roms/savestates` | `/<hostname>/saves` |

### Key Features

- **One script, all OSes** — auto-detects MuOS / Knulli / RockNix at runtime
- **Per-device cloud isolation** — each device syncs to its own cloud folder
- **Smart timestamp sync** — `--update` flag only transfers newer files (bidirectional-safe)
- **macOS junk filtering** — excludes `._*`, `.DS_Store`, `__MACOSX`, media files
- **RockNix dual-dir support** — syncs both `savestates/` and `savefiles/` separately
- **Dropbox / Google Drive / OneDrive** — any rclone-supported provider

## Repository Structure

```
scripts/                          Universal scripts (work on ALL CFWs)
  cloud_upload_saves.sh           Upload saves + screenshots to cloud
  cloud_download_saves.sh         Download saves + screenshots from cloud

platforms/                        Per-OS install scripts
  muos/install.sh                 Deploys to /mnt/mmc/MUOS/tasks/ + Tools/
  knulli/install.sh               Installs rclone + scripts to /userdata/system/
  rocknix/install.sh              Deploys to /storage/.config/modules/

copy_to_tasks_directory/          Legacy MuOS-only scripts (backup/pixie formats)
copy_to_tools_directory/          PNG icons for MuOS task menu
rclone_sample_conf_for_dropbox/   Sample rclone config — Dropbox
rclone_sample_conf_for_gdrive/    Sample rclone config — Google Drive
rclone_sample_conf_for_onedrive/  Sample rclone config — OneDrive
```

## Quick Start

### Step 1: Configure rclone on your computer

See **[Setup Rclone Configuration](./1-Setup-Rclone-Configuration.md)** — generate an
`rclone.conf` with your cloud provider credentials (Dropbox, Google Drive, or OneDrive).

### Step 2: Install on your device

#### MuOS (Brick, RG40XXH, etc.)
```bash
# Push scripts + installer to device, then run
scp -r scripts/ platforms/muos/ root@DEVICE_IP:/tmp/
ssh root@DEVICE_IP 'sh /tmp/muos/install.sh'
```

#### Knulli / Batocera (RG40XXH)
```bash
# Installer auto-downloads rclone arm64 and deploys everything
scp -r scripts/ platforms/knulli/ rclone.conf root@DEVICE_IP:/tmp/
ssh root@DEVICE_IP 'sh /tmp/knulli/install.sh'
```

#### RockNix (MiniLoong Pocket 1)
```bash
# rclone already pre-installed — just push scripts
scp -r scripts/ platforms/rocknix/ root@DEVICE_IP:/tmp/
ssh root@DEVICE_IP 'sh /tmp/rocknix/install.sh'
```

### Step 3: Run cloud sync

```bash
# Upload saves to cloud (run after playing)
cloud_upload_saves.sh

# Download saves from cloud (run before playing on a different device)
cloud_download_saves.sh
```

On MuOS these appear in: **Applications -> Task Toolkit -> Backup**

## How Sync Works

Both operations use `rclone copy --update` which only transfers files that are
**newer** than the destination — this makes upload and download bidirectionally safe:

- **Upload:** only pushes local saves newer than the cloud versions
- **Download:** only pulls cloud saves newer than your local versions
- **Multi-device:** play on Device A, upload; play on Device B, download — only newer saves transfer

Each device syncs to its own cloud folder (`/<device-name>/saves/`), preventing
cross-device timestamp collisions. Saves from different devices never overwrite
each other — each device's cloud folder is independent.

## Cloud Folder Naming

| CFW | Source | Example |
|-----|--------|---------|
| MuOS | `/opt/muos/device/config/board/name` | `tui-brick`, `rg40xx-h` |
| Knulli | `/userdata/system/configs/cloud-sync.conf` | `rg40xx-h` (editable) |
| RockNix | `hostname` | `pocket1` |

To change the Knulli device name, edit:
```
/userdata/system/configs/cloud-sync.conf
```

## Excludes

The following are always excluded from sync (inlined in scripts per busybox
word-splitting safety):

- Legacy duplicate dirs (`saves/`, `screenshot/`, `podcaster/`, `pico8/`)
- Media files (mp3, m4a, ogg, flac, wav, mp4, mkv, avi, mov)
- Database/temp files (.db, .old, .bak, .tmp)
- macOS junk (.DS_Store, ._\*, .Spotlight-V100, .fseventsd)

## Cloud Drive Rules

Cloud drives are **SAVE/STATE data only** — never ROMs, BIOS, installers, or media.
ROMs come from local shares/SD cards, not cloud.

## Acknowledgments

Adapted from **hotcereal**'s [cloud-saves-miyoo-mini-plus](https://github.com/hotcereal/cloud-saves-miyoo-mini-plus)
for the Miyoo Mini Plus, originally ported to MuOS, then generalized for all CFWs.

## License

MIT — see [LICENSE](./LICENSE).
