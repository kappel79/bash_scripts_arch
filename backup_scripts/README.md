# backup_root.sh usage

## 1. Prepare the script
1. Copy `backup_root.sh` into a directory you control (example: `/home/razer/Documents/backup_scripts`).
2. Make it executable:
   ```bash
   chmod +x /home/USERNAME/Documents/backup_scripts/backup_root.sh
   ```

## 2. Run a manual backup
1. Mount the destination drive (default expected mount: `/mnt/nvme_data`).
2. Start the backup as root so ownership, ACLs, and xattrs are preserved:
   ```bash
   sudo /home/USERNAME/Documents/backup_scripts/backup_root.sh
   ```
3. Snapshots land under `/mnt/nvme_data/backup_live/rsync/<timestamp>` and the latest run is symlinked at `/mnt/nvme_data/backup_live/rsync/latest`.

## 3. Customizing for another PC
- **Destination path**: change the `DEST_BASE` constant near the top of `backup_root.sh` to point at your preferred mount or directory.
- **Source filesystem**: the script backs up `/` by default (`SRC="/"`). Adjust if you only need to capture a subset.
- **Mount validation**: `ensure_destination()` confirms the backup path resides on a mounted filesystem; edit this logic if your layout differs.

## 4. Exclusions
The `EXCLUDES` array in `backup_root.sh` lists folders that rsync skips (e.g., `/dev/*`, `/proc/*`, `/mnt/nvme_data/backup_live/*`). Edit that array to add or remove paths such as caches (`/var/cache/*`, `/home/*/.cache`) before running the script.

## 5. Restore instructions
See `restoreme/README.md` for a step-by-step restore guide using the snapshots created by this script.


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