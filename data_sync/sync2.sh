#!/bin/bash

cat << "EOF"
    ▘▖▖
▌▌▛▌▌▚▘
▙▌▌▌▌▌▌

▄▖▄▖▄▖▄▖  ▄ ▄▖▄▖▖▖▖▖▄▖  ▄▖  ▄▖
▐ ▌▌▙▌▙▖  ▙▘▌▌▌ ▙▘▌▌▙▌  ▄▌  ▛▌
▐ ▛▌▌ ▙▖  ▙▘▛▌▙▖▌▌▙▌▌   ▙▖▗ █▌


                          ▄▖        ▘  ▌ ▗
                          ▌ ▛▌▛▌▌▌▛▘▌▛▌▛▌▜▘
                          ▙▖▙▌▙▌▙▌▌ ▌▙▌▌▌▐▖
                              ▌ ▄▌   ▄▌
                                  ▄▖▄▖▄▖▄▖
                                  ▄▌▛▌▄▌▙▖
                                  ▙▖█▌▙▖▄▌

                          ▌         ▜ ▄▖▄▖
                          ▙▘▀▌▛▌▛▌█▌▐  ▌▙▌
                          ▛▖█▌▙▌▙▌▙▖▐▖ ▌▄▌
                              ▌ ▌
Sync Live-Image folder to SUSE server
EOF

# Sync script for backing up backup_live directory to remote server
# Target: 192.168.0.175:/mnt/orf/Data/

TARGET_HOST="192.168.0.175"
TARGET_USER="razer"
TARGET_PATH="/mnt/orf/Data/"


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
    /mnt/nvme_data/backup_live \
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
