


# SUSE Backup Scripts

This collection contains Bash scripts designed to perform full partition backups using `dd` piped through `zstd` for compression. They also generate SHA-512 checksums for verification.

## Scripts Overview

### `backup_dd_root.sh`
*   **Target:** Root partition (`nvme0n1p2`)
*   **Source Path:** Defined as `dev/nvme0n1p2` in the script.
*   **Output:** Saves to `/mnt/orf/Data/backup_live/suse_nvme/` with filename `suse_root_<DATE>.img.zst`.

### `backup_dd.sh`
*   **Target:** Boot/EFI partition (`/dev/nvme0n1p1`)
*   **Source Path:** Defined as `/dev/nvme0n1p1`.
*   **Output:** Saves to `/mnt/orf/Data/backup_live/suse_nvme/` with filename `suse_boot_<DATE>.img.zst`.

## Prerequisites

*   **Root Privileges:** Scripts must be run with `sudo` or as root.
*   **Dependencies:**
    *   `dd`
    *   `zstd`
    *   `sha512sum`
*   **Destination:** Ensure the destination directory `/mnt/orf/Data/backup_live/suse_nvme/` exists or is writable (scripts attempt to create it).

## Usage

```bash
sudo ./backup_dd_root.sh
sudo ./backup_dd.sh
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
