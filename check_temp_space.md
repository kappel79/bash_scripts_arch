check_temp_space.sh

Quick helper to inspect the size of common temp, cache, and log directories plus the overall disk and journal usage. Great for deciding what to clean when free space starts shrinking.

Setup

Make sure the script is executable:

chmod +x check_temp_space.sh

Usage

Run it from the repository root:

./check_temp_space.sh

The script will print:
- `df -h` for a snapshot of mounted disks
- A sorted `du -sh` listing for the monitored temp/cache folders
- `journalctl --disk-usage` so you know how much space the systemd journal consumes

Options & tips

- Run with sudo if your user lacks permission to inspect certain system directories.
- Edit the `paths=( ... )` array near the top of the script to add or remove directories that matter to you.
- Pipe the output into a log (`./check_temp_space.sh | tee space_report.txt`) for later review.
- Use `watch -n 300 ./check_temp_space.sh` to keep an eye on fast-growing folders during troubleshooting.


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