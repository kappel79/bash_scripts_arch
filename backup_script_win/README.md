# Windows 11 Backup Script

This script creates a full disk backup of a Windows 11 installation using `dd` and compresses it with `zstd`.

## Disclaimer

**USE THIS SCRIPT AT YOUR OWN RISK.** Disk imaging is a powerful tool, but improper use can lead to data loss. Always double-check your source and destination paths.

## Usage

1.  **Make the script executable:**
    Before running the script, you need to give it execute permissions.

    ```bash
    chmod +x backup_dd_win11.sh
    ```

2.  **Run the script:**
    The script needs low-level access to the disk, so it must be run with `sudo`.

    ```bash
    sudo ./backup_dd_win11.sh
    ```

## How It Works

### Disk Identification

The script uses the `/dev/disk/by-id/` path to identify the source disk. This is a more reliable method than using `/dev/sda` or `/dev/nvme0n1` because device names can change between reboots, especially if you have multiple disks. The `by-id` path creates a unique and persistent symlink for each storage device based on its hardware serial number.

This ensures that you are always backing up the correct disk, preventing catastrophic mistakes. The script backs up the *entire* disk, including all partitions (bootloader, main partition, recovery partitions, etc.).

### Block Size (`bs=4M`)

The `bs=4M` parameter in the `dd` command tells it to read and write data in 4-megabyte chunks. This block size is chosen as a balance between performance and resource usage.

-   **Larger block sizes** generally lead to faster transfer speeds because the system makes fewer individual read/write calls.
-   **Smaller block sizes** can be slower but may be more resilient on older systems or with less stable hardware.

A block size of `4M` is a common and effective choice for modern systems, providing good throughput for disk imaging operations.

## How to Restore the Backup

Restoring the disk image requires booting into a live Linux environment (like an Arch Linux, Ubuntu, or Fedora live USB). The target disk for the restore should be at least **2TB** or larger than the original disk.

**Warning:** The following command will completely overwrite the contents of the destination disk. Make sure you have selected the correct one.

1.  **Boot into a live Linux environment.**

2.  **Identify the destination disk.** Use a command like `lsblk` or `fdisk -l` to list the available disks and find the one you want to restore to. **Be absolutely certain about the device name.**

3.  **Restore the image.** Use the `zstdcat` and `dd` commands to decompress the image and write it to the new disk.

    ```bash
    zstdcat /path/to/your/win11_nvme_DDMMYYYY.img.zst | sudo dd of=/dev/sdX bs=4M status=progress
    ```

    -   Replace `/path/to/your/win11_nvme_DDMMYYYY.img.zst` with the actual path to your backup file.
    -   Replace `/dev/sdX` with the correct device name for your new disk (e.g., `/dev/sda`, `/dev/nvme0n1`).

4.  **Verify (Optional but Recommended):** After the `dd` command finishes, you can try to mount the partitions from the new disk to ensure the data was written correctly.

## Copyright and License

Copyright (C) 2025 kappel79

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
