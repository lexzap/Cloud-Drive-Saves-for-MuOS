📥 Rclone Cloud Configuration Guide (Google Drive, OneDrive, Dropbox)
====================================================================

This guide will help you configure rclone to access your cloud storage accounts using a web browser on your desktop or laptop.

Prerequisites:
--------------
- A computer running macOS, Windows, or Ubuntu
- An active internet connection
- A web browser installed (e.g., Chrome, Firefox)
- rclone installed on your system

If rclone is not installed, you can download it from:
https://rclone.org/downloads/

General Steps:
--------------
1. Open a terminal (Command Prompt on Windows).
2. Run the command:
   rclone config
3. Follow the prompts to set up a new remote for your desired cloud service.

Detailed Instructions for Each Cloud Service:
---------------------------------------------

### Google Drive
1. Run:
   rclone config
2. At the prompt, type 'n' to create a new remote.
3. Enter a name for the remote (e.g., 'gdrive').
4. When prompted for the storage type, type 'drive'.
5. For client_id and client_secret, press Enter to use rclone's defaults. (Optional: You can create your own credentials for increased API quotas.)
6. For scope, choose the desired access level:
   - 1: Full access
   - 2: Read-only access
7. When asked if you want to use auto config, type 'y'.
8. A browser window will open prompting you to log in to your Google account and authorize rclone.
9. After authorization, return to the terminal and confirm the configuration.

Reference: https://rclone.org/drive/

### OneDrive
1. Run:
   rclone config
2. At the prompt, type 'n' to create a new remote.
3. Enter a name for the remote (e.g., 'onedrive').
4. When prompted for the storage type, type 'onedrive'.
5. For client_id and client_secret, press Enter to use rclone's defaults. (Optional: You can create your own credentials via Azure Portal.)
6. When asked if you want to use auto config, type 'y'.
7. A browser window will open prompting you to log in to your Microsoft account and authorize rclone.
8. After authorization, return to the terminal and confirm the configuration.

Reference: https://rclone.org/onedrive/

### Dropbox
1. Run:
   rclone config
2. At the prompt, type 'n' to create a new remote.
3. Enter a name for the remote (e.g., 'dropbox').
4. When prompted for the storage type, type 'dropbox'.
5. For client_id and client_secret, press Enter to use rclone's defaults. (Optional: You can create your own app in the Dropbox App Console.)
6. When asked if you want to use auto config, type 'y'.
7. A browser window will open prompting you to log in to your Dropbox account and authorize rclone.
8. After authorization, return to the terminal and confirm the configuration.

Reference: https://rclone.org/dropbox/

After Configuration:
--------------------
- Your rclone configuration is stored in a file named 'rclone.conf'.
- The default location is:
  - macOS/Linux: ~/.config/rclone/rclone.conf
  - Windows: C:\Users\YourUsername\.config\rclone\rclone.conf
- You can copy this file to other devices (e.g., muOS Pixie) to replicate the configuration.

For more information and advanced configurations, visit:
https://rclone.org/docs/
