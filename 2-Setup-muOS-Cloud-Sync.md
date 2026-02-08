# 📥 muOS Cloud Sync Setup Guide

*Set up cloud synchronization (upload/download) on your muOS device using rclone*

---

This guide will help you set up cloud synchronization on your muOS device (Goose release) using the rclone configuration you created on your computer.

## 📋 Prerequisites

- ✅ A desktop computer with internet access (macOS, Windows, or Ubuntu)
- ✅ An SD card reader to access the muOS SD card
- ✅ Internet connection on your Anbernic device (if required by your cloud service)
- ✅ Completed rclone configuration from [Step 1](./1-Setup-Rclone-Configuration.md)

## 📁 Step 1: Download the ARMv7 rclone Binary

1. On your desktop computer, open a web browser and navigate to the rclone downloads page:
   
   🌐 **[https://rclone.org/downloads/](https://rclone.org/downloads/)**

2. Scroll down to the **"Linux ARM - 32 Bit"** section

3. Click on the link to download the latest ARMv7 binary
   
   Example: `rclone-v1.69.2-linux-arm-v7.zip`

4. Once downloaded, extract the zip file to obtain the `rclone` executable

## 💾 Step 2: Insert the OS SD Card (SD1)

1. **Power off** your Anbernic device
2. **Remove** the OS SD card (usually the first slot)
3. **Insert** the SD card into your computer using an SD card reader

## 📂 Step 3: Transfer Files to the SD Card

1. Open the main OS SD card on your computer. It should have a directory named `MUOS` , on your device this typically at `/mnt/mmc/MUOS/`  

### 📝 Important Note for qty=2 SD card users OS and a ROMs SD card: 
the files being copied should go into SD slot #1 that has the MUOS operating system.

2. **Create the tools directory if needed:** Navigate to the `MUOS` folder and check if a `tools` directory exists. If not, create it:
   - **Windows/macOS:** Right-click in the MUOS folder → New Folder → Name it `tools`
   - **Linux:** Create the directory if it doesn't exist

3. **Choose your installation path for muOS Goose:**

> **Important:** The task directory `/opt/muos/share/task` is on the Linux system partition, not the SD card’s FAT partition. macOS/Windows can’t write to it directly. You must use **SSH/SCP** to copy task scripts and set permissions.

### 🔧 Required File Transfers:

**For muOS Goose:**
| Source (from this repository) | Destination on SD Card |
|-------------------------------|------------------------|
| `rclone` armv7 32-bit linux binary (downloaded separately) | `MUOS/tools/rclone` |
| `rclone.conf` file (from your PC setup) | `MUOS/tools/rclone.conf` |
| `copy_to_tools_directory/Cloud_Upload_Saves.png` | `MUOS/tools/Cloud_Upload_Saves.png` |
| `copy_to_tools_directory/Cloud_Download_Saves.png` | `MUOS/tools/Cloud_Download_Saves.png` |

**🦆 For muOS Goose users:**
| Source (from this repository) | Destination on SD Card |
|-------------------------------|------------------------|
| `copy_to_tasks_directory/backup/cloud_upload_saves.sh` | `/opt/muos/share/task/cloud_upload_saves.sh` |
| `copy_to_tasks_directory/backup/cloud_download_saves.sh` | `/opt/muos/share/task/cloud_download_saves.sh` |

### 🔐 Copy via SSH/SCP (required for /opt/muos/share/task)

Example (replace host and folder as needed):

```bash
# Create a folder (optional)
ssh root@YOUR_DEVICE_IP 'mkdir -p "/opt/muos/share/task/Rclone Tasks"'

# Copy scripts
scp copy_to_tasks_directory/backup/cloud_upload_saves.sh \
   copy_to_tasks_directory/backup/cloud_download_saves.sh \
   root@YOUR_DEVICE_IP:"/opt/muos/share/task/Rclone Tasks/"

# Set executable permissions
ssh root@YOUR_DEVICE_IP \
   'chmod +x "/opt/muos/share/task/Rclone Tasks/cloud_upload_saves.sh" \
   "/opt/muos/share/task/Rclone Tasks/cloud_download_saves.sh"'
```

> **🔐 SSH Login Note:** Most users connect as `root` and enter the default muOS password (or whatever you changed it to). If you use keys, add `-i ~/.ssh/your_key` to the commands.

> **📝 Important Notes:** 
> - Copy your `rclone.conf` file that you configured with your cloud service from your PC (Step 1)
> - The PNG icon files are optional but will provide custom icons for your tasks if your theme supports them
> - For Goose, copy the scripts from `copy_to_tasks_directory/backup/` to `/opt/muos/share/task/` on the device via SSH (this is on the muOS system partition, not the SD card FAT partition)
> - All files from `copy_to_tools_directory/` go to `MUOS/tools/` on your SD card

## ⚙️ Step 4: Set Executable Permissions

**For macOS and Linux users only:**

If you're using a Unix-based system, ensure the scripts and rclone binary are executable:

1. Open **Terminal**
2. Navigate to the MUOS directory on the SD card
3. Run the following commands:

```bash
chmod +x tools/rclone
```

**Set permissions for Goose task scripts (must be run via SSH on the device):**

```bash
ssh root@DEVICE_IP "chmod +x /opt/muos/share/task/cloud_upload_saves.sh"
ssh root@DEVICE_IP "chmod +x /opt/muos/share/task/cloud_download_saves.sh"
```

> **💡 Tip:** Replace `DEVICE_IP` with your device's IP address. You can also set executable permissions for all shell scripts at once:
> ```bash
> ssh root@DEVICE_IP "chmod +x /opt/muos/share/task/*.sh"
> ```

## 🔄 Step 5: Reinsert the SD Card and Access Tasks

1. **Safely eject** the SD card from your computer
2. **Insert** the SD card back into your Anbernic device
3. **Power on** the device
4. **Navigate** to the Tasks menu:
   - **Goose**: Applications → Task Toolkit → Backup
5. You should see:
    - 📤 **Cloud Upload Saves**
    - 📥 **Cloud Download Saves**
6. **Select** the desired task to execute the corresponding script

## 📝 Important Notes

> **🌐 Internet Connection:** Ensure your device is connected to the internet if your cloud service requires it

> **⏰ Time Sync Critical:** Enable internet time synchronization in muOS settings to ensure proper timestamps on save files. Incorrect timestamps can cause sync conflicts and file versioning issues

> **🔗 Compatibility:** The tasks utilize symlinked paths (`/mnt/mmc/MUOS/`) for compatibility across different storage setups

> **🎯 muOS Version Support:** This setup supports Goose release tasks under `/opt/muos/share/task`

> **⚙️ Customization:** Customize the scripts as needed to match your specific directory structures or cloud service configurations

## 📚 Additional Resources

For more information on muOS and its features, visit:

🌐 **[https://muos.dev/help/addcontent](https://muos.dev/help/addcontent)**

---

## 🎯 Quick Setup Checklist

- [ ] Downloaded ARMv7 rclone binary from rclone.org
- [ ] Copied rclone binary to `MUOS/tools/rclone`
- [ ] Copied your rclone.conf (from Step 1) to `MUOS/tools/rclone.conf`
- [ ] Copied PNG files from `copy_to_tools_directory/` to `MUOS/tools/`
- [ ] **For Goose**: Copied shell scripts from `copy_to_tasks_directory/backup/` to `/opt/muos/share/task/`
- [ ] Set executable permissions (Unix systems)
- [ ] Tested cloud upload/download tasks

*Previous step: [Setup Rclone Configuration](./1-Setup-Rclone-Configuration.md)*
