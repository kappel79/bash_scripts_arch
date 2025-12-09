#!/bin/bash

cat << "EOF"
                               _     _            __  __
                              | |   (_)_ __  _   _\ \/ /
                              | |   | | '_ \| | | |\  /
                              | |___| | | | | |_| |/  \
  _____  _    ____  _____   __|_____|_|_|_|_|\__,_/_/\_\ ____
 |_   _|/ \  |  _ \| ____| | __ )  / \  / ___| |/ / | | |  _ \
   | | / _ \ | |_) |  _|   |  _ \ / _ \| |   | ' /| | | | |_) |
   | |/ ___ \|  __/| |___  | |_) / ___ \ |___| . \| |_| |  __/
   |_/_/   \_\_|   |_____| |____/_/   \_\____|_|\_\\___/|_|       _ _____ ___
                                      | | ____ _ _ __  _ __   ___| |___  / _ \
                                      | |/ / _` | '_ \| '_ \ / _ \ |  / / (_) |
                                      |   < (_| | |_) | |_) |  __/ | / / \__, |
                                      |_|\_\__,_| .__/| .__/ \___|_|/_/    /_/
                                                |_|   |_|
Sync /home Folder to SUSE server

EOF

# Sync script for backing up home directory to remote server
# Target: 192.168.0.175:/mnt/orf/Data/arch_home

TARGET_HOST="192.168.0.175"
TARGET_USER="razer"
TARGET_PATH="/mnt/orf/Data/arch_home"
EXCLUDE_FILE="exclude-home.txt"

# Check if target host is available
if ! ping -c 1 -W 2 "$TARGET_HOST" &> /dev/null; then
    echo "Error: Target host $TARGET_HOST is not available"
    exit 1
fi

# Change to home directory
cd ~ || exit 1

# Run rsync with progress info only (no verbose file listing)
rsync -ah \
    --exclude-from="$EXCLUDE_FILE" \
    /home/razer \
    "$TARGET_USER@$TARGET_HOST:$TARGET_PATH" \
    --info=progress2 2>&1 | tee /tmp/rsync_output.log

# Extract file count and total size from rsync output log
file_count=$(grep -oP '(?<=^Number of files: )[0-9,]+' /tmp/rsync_output.log | tail -1)
total_bytes=$(grep -oP 'sent \K[0-9.]+' /tmp/rsync_output.log | tail -1)

# Convert bytes to MB
if [ -n "$total_bytes" ]; then
    total_mb=$(echo "scale=2; $total_bytes / 1048576" | bc)
else
    total_mb="0"
fi

echo ""
echo "Sync completed successfully"
if [ -n "$file_count" ]; then
    echo "Files synced: $file_count"
fi
echo "Transfer info: ${total_mb} MB"
