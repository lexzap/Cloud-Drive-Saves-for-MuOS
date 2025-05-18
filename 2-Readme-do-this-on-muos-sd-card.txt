📥 muOS Pixie: Cloud Sync Setup Guide
-------------------------------------

This guide will help you set up cloud synchronization (upload/download) on your muOS Pixie device using rclone.

Prerequisites:
- A desktop computer with internet access (macOS, Windows, or Ubuntu)
- An SD card reader to access the muOS SD card
- Internet connection on your Anbernic device (if required by your cloud service)

📁 Step 1: Download the ARMv7 rclone Binary
------------------------------------------
1. On your desktop computer, open a web browser and navigate to the rclone downloads page:
   https://rclone.org/downloads/

2. Scroll down to the "Linux ARM - 32 Bit" section.

3. Click on the link to download the latest ARMv7 binary (e.g., `rclone-v1.69.2-linux-arm-v7.zip`).

4. Once downloaded, extract the zip file to obtain the `rclone` executable.


📁 Step 2: Insert the OS SD Card (SD1)
--------------------------------------
1. Power off your Anbernic device.

2. Remove the OS SD card (usually the first slot).

3. Insert the SD card into your computer using an SD card reader.


📁 Step 3: Transfer Files to the SD Card
---------------------------------------
1. Open the SD card on your computer. It should have a directory named 'MUOS' typically  '/mnt/mmc/MUOS/'.

2. Navigate to the following directories and copy the respective files:

   - Copy the `rclone` binary to:
     MUOS/tools/rclone

   - Copy your `rclone.conf` file (configured with your cloud service that you did on your PC) to:
     MUOS/tools/rclone.conf

   - Copy the shell scripts to:
     MUOS/tasks/Cloud_Upload_Saves.sh
     MUOS/tasks/Cloud_Download_Saves.sh

   - Copy the task files to:
     MUOS/tasks/Cloud_upload_Saves.task
     MUOS/tasks/Cloud_Download_Saves.task



📁 Step 4: Set Executable Permissions (if necessary)
----------------------------------------------------
If you're using a Unix-based system (macOS or Linux), ensure the scripts and rclone binary are executable:

   - Open Terminal.

   - Navigate to the MUOS directory on the SD card.

   - Run the following commands:

     chmod +x tools/rclone
     chmod +x tasks/cloud_upload_saves.sh
     chmod +x tasks/cloud_download_saves.sh


📁 Step 5: Reinsert the SD Card and Access Tasks
-----------------------------------------------
1. Safely eject the SD card from your computer.

2. Insert the SD card back into your Anbernic device.

3. Power on the device.

4. Navigate to the 'Tasks' menu in muOS Pixie.

5. You should see:
   - Cloud Upload Saves
   - Cloud Download Saves

6. Select the desired task to execute the corresponding script.

📁 Notes:
--------
- Ensure your device is connected to the internet if your cloud service requires it.

- The tasks utilize symlinked paths (/mnt/mmc/MUOS/) for compatibility across different storage setups.

- Customize the scripts as needed to match your specific directory structures or cloud service configurations.

For more information on muOS Pixie and its features, visit:
https://muos.dev/help/addcontent
