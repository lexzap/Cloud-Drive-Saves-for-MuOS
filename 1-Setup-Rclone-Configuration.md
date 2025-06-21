# 📥 Rclone Cloud Configuration Guide

*Configure rclone for Google Drive, OneDrive, and Dropbox*

---

This guide will help you configure rclone to access your cloud storage accounts using a web browser on your desktop or laptop.

## 📋 Prerequisites

- A computer running macOS, Windows, or Linux OS
- An active internet connection
- A web browser installed (e.g., Chrome, Firefox)
- rclone installed on your system

> **💡 Note:** If rclone is not installed, you can download it from: [https://rclone.org/downloads/](https://rclone.org/downloads/)

## 🚀 General Steps

1. Open a terminal (Command Prompt on Windows)
2. Run the command:
   ```bash
   rclone config
   ```
3. Follow the prompts to set up a new remote for your desired cloud service

## ☁️ Cloud Service Configuration

### 🔵 Google Drive

1. Run:
   ```bash
   rclone config
   ```
2. At the prompt, type `n` to create a new remote
3. Enter a name for the remote (e.g., `gdrive`)
4. When prompted for the storage type, type `drive`
5. For `client_id` and `client_secret`, press Enter to use rclone's defaults
   > *Optional: You can create your own credentials for increased API quotas*
6. For scope, choose the desired access level:
   - **1**: Full access
   - **2**: Read-only access
7. When asked if you want to use auto config, type `y`
8. A browser window will open prompting you to log in to your Google account and authorize rclone
9. After authorization, return to the terminal and confirm the configuration

📖 **Reference:** [https://rclone.org/drive/](https://rclone.org/drive/)

### 🔷 OneDrive

1. Run:
   ```bash
   rclone config
   ```
2. At the prompt, type `n` to create a new remote
3. Enter a name for the remote (e.g., `onedrive`)
4. When prompted for the storage type, type `onedrive`
5. For `client_id` and `client_secret`, press Enter to use rclone's defaults
   > *Optional: You can create your own credentials via Azure Portal*
6. When asked if you want to use auto config, type `y`
7. A browser window will open prompting you to log in to your Microsoft account and authorize rclone
8. After authorization, return to the terminal and confirm the configuration

📖 **Reference:** [https://rclone.org/onedrive/](https://rclone.org/onedrive/)

### 🟦 Dropbox

1. Run:
   ```bash
   rclone config
   ```
2. At the prompt, type `n` to create a new remote
3. Enter a name for the remote (e.g., `dropbox`)
4. When prompted for the storage type, type `dropbox`
5. For `client_id` and `client_secret`, press Enter to use rclone's defaults
   > *Optional: You can create your own app in the Dropbox App Console*
6. When asked if you want to use auto config, type `y`
7. A browser window will open prompting you to log in to your Dropbox account and authorize rclone
8. After authorization, return to the terminal and confirm the configuration

📖 **Reference:** [https://rclone.org/dropbox/](https://rclone.org/dropbox/)

## ✅ After Configuration

Your rclone configuration is stored in a file named `rclone.conf`.

### 📁 Default Locations:
- **macOS/Linux:** `~/.config/rclone/rclone.conf`
- **Windows:** `C:\Users\YourUsername\.config\rclone\rclone.conf`

> **🎯 Important for muOS Setup:** This `rclone.conf` file will be used in Step 2 to copy to your muOS handheld's root OS SD card. Make note of the file location as you'll need to transfer it to your handheld device.

> **💡 Tip:** You can copy this file to other devices (e.g., muOS Pixie) to replicate the configuration.

## 📚 Additional Resources

For more information and advanced configurations, visit: [https://rclone.org/docs/](https://rclone.org/docs/)

---

*Next step: [Setup muOS Pixie Cloud Sync](./2-Setup-muOS-Cloud-Sync.md)*
