# Restore Procedure

1. Boot into a live environment or single-user shell where the backup drive and the target partition can be mounted safely.
2. Mount the target partition (example uses `/dev/sda1` as root) and the backup disk if it is not already mounted:
   ```bash
   sudo mount /dev/sda1 /mnt/restore_target
   sudo mount /dev/nvmeXn1pY /mnt/nvme_data   # adjust as needed
   ```
3. Run `rsync` to copy everything from the desired snapshot (e.g., `latest` or a timestamped directory) back to the target. Keep the trailing slashes:
   ```bash
   sudo rsync -aAXHv --numeric-ids --delete \
       /mnt/nvme_data/backup_live/latest/ \
       /mnt/restore_target/
   ```
4. Inspect key directories (`/etc`, `/home`, `/boot`) on `/mnt/restore_target` to confirm ownership and permissions look correct, and update `fstab` or bootloader configs if disk identifiers changed.
5. When satisfied, unmount the target and reboot:
   ```bash
   sudo umount /mnt/restore_target
   sudo reboot
   ```

To restore only specific folders, restrict the `rsync` command to those paths instead of the entire snapshot.


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