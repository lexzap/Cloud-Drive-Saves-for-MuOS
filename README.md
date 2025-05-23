# 📥 muOS Cloud Sync for Retro Handheld Devices

*Automated cloud backup solution for save files and screenshots on muOS Pixie*

---

## 🎮 Overview

This project provides a complete cloud synchronization solution for **muOS retro handheld devices**, specifically designed and tested for the **muOS Pixie release**. It allows you to automatically backup and restore your precious save files and screenshots to popular cloud storage services.

### ✨ Key Features

- 🔄 **Bidirectional Sync**: Upload saves to cloud and download from cloud
- 💾 **Save File Backup**: Automatically backs up all game save files
- 📸 **Screenshot Backup**: Preserves your gaming screenshots
- 🎯 **Easy Integration**: Adds new tasks directly to muOS Task menu
- ⚡ **One-Click Operation**: Simple task execution from device menu

## 🙏 Acknowledgments

This project is adapted from the excellent work by **hotcereal** for the Miyoo Mini Plus:

🌟 **Original Project:** [cloud-saves-miyoo-mini-plus](https://github.com/hotcereal/cloud-saves-miyoo-mini-plus)

*Special thanks to hotcereal for creating the foundation that made this muOS adaptation possible!*

## 🌐 Cloud Service Compatibility

- ✅ **Dropbox** - Fully tested and working
- 🔧 **Google Drive** - Should work (configuration included)
- 🔧 **OneDrive** - Should work (configuration included)
- 🔧 **Other rclone-supported services** - May work with proper configuration

> **⚠️ Important Disclaimer:** This software is provided as-is under the MIT License. Users are responsible for their own files and data. **I take no responsibility for any data loss, corruption, or other issues that may arise from using this software.** Always backup your files independently before using any cloud sync solution.

## 🚀 What This Does

When installed, this project adds **two new tasks** to your muOS Pixie device's Task menu:

1. **📤 Cloud Upload Saves** - Uploads your save files and screenshots to cloud storage
2. **📥 Cloud Download Saves** - Downloads your save files and screenshots from cloud storage

### 📁 Directories Synchronized

- `/run/muos/storage/save/` - All game save files
- `/run/muos/storage/screenshot/` - All screenshots

## 📋 Requirements

- muOS Pixie release (or compatible muOS version)
- Desktop computer for initial setup
- SD card reader
- Internet connection on your handheld device
- Cloud storage account (Dropbox, Google Drive, OneDrive, etc.)

## 🛠️ Installation Guide

Follow these step-by-step guides to set up cloud sync. **Complete them in order:**

### 🖥️ **Step 1: Configure Rclone on Your Computer**
**[📝 Setup Rclone Configuration Guide](./1-Setup-Rclone-Configuration.md)**

*Do this first on your desktop/laptop computer:*
- Install and configure rclone using your web browser
- Set up authentication for your cloud service (Dropbox, Google Drive, OneDrive)
- Generate the `rclone.conf` configuration file
- **Required before proceeding to Step 2**

### 📱 **Step 2: Install Cloud Sync on Your Handheld**
**[⚙️ muOS Cloud Sync Setup Guide](./2-Setup-muOS-Cloud-Sync.md)**

*Do this after completing Step 1:*
- Download ARMv7 rclone binary for your handheld device
- Transfer files to your muOS SD card
- Install and configure the cloud sync tasks
- Test the new Tasks in your muOS menu

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](./LICENSE) file for details.

## ⚠️ Disclaimer

**USE AT YOUR OWN RISK**: This software is experimental and provided without warranty. Always maintain independent backups of your important save files and data. The author assumes no responsibility for any data loss, device issues, or other problems that may result from using this software.

## 🤝 Contributing

Found an issue or want to improve the project? Feel free to open an issue or submit a pull request!

---

*Happy gaming and safe saving! 🎮✨* 
