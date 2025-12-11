


# Pi5 Backup Scripts

This collection contains Bash scripts designed to perform full partition backups using `dd` piped through `zstd` for compression. They also generate SHA-512 checksums for verification.

## Scripts Overview

### `backup_dd_root.sh`
*   **Target:** Root partition (`/dev/disk/by-uuid/37d2cb52-513e-40e1-b90f-213aa6096cba`)
*   **Source Path:** Defined as `37d2cb52-513e-40e1-b90f-213aa6096cba` in the script.
*   **Output:** Saves to `/mnt/sda/backups_pi5` with filename `pi5_root_<DATE>.img.zst`.

### `backup_dd.sh`
*   **Target:** Boot/EFI partition (`/dev/disk/by-uuid/27E7-00CE`)
*   **Source Path:** Defined as `27E7-00CE`.
*   **Output:** Saves to `/mnt/sda/backups_pi5` with filename `pi5_boot_<DATE>.img.zst`.

## Prerequisites

*   **Root Privileges:** Scripts must be run with `sudo` or as root.
*   **Dependencies:**
    *   `dd`
    *   `zstd`
    *   `sha512sum`
*   **Destination:** Ensure the destination directory `/mnt/sda/backups_pi5` exists or is writable (scripts attempt to create it).

## Usage

```bash
sudo ./backup_dd_root.sh
sudo ./backup_dd.sh
```

## How to Restore

Restoring a partition requires decompressing the `.zst` file and writing the image to the target device using `dd`.

**Warning:** This is a destructive operation. Ensure you are restoring to the correct partition to avoid data loss.

### Restore Root Partition

To restore the root partition, use `zstdcat` to decompress the backup and pipe it to `dd`. Replace `/path/to/your/backup.img.zst` with the actual path to your root backup file.

```bash
zstdcat /path/to/your/pi5_root_YYYY-MM-DD.img.zst | sudo dd of=/dev/nvme0n1p2 bs=4M status=progress
```

### Restore Boot Partition

Similarly, to restore the boot partition, use the following command, replacing the path with your boot backup file:

```bash
zstdcat /path/to/your/pi5_boot_YYYY-MM-DD.img.zst | sudo dd of=/dev/nvme0n1p1 bs=4M status=progress
```

---

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
    along with this program.  If not, see <http://www.gnu.org/licenses/
