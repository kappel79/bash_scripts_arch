#!/usr/bin/env bash

cat << "EOF"

 █████╗ ██████╗  ██████╗██╗  ██╗     █████╗ ██╗    ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗   
██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔══██╗██║    ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝   
███████║██████╔╝██║     ███████║    ███████║██║    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝    
██╔══██║██╔══██╗██║     ██╔══██║    ██╔══██║██║    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗    
██║  ██║██║  ██║╚██████╗██║  ██║    ██║  ██║██║    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗   
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝   
                                                                                            
                    ██████╗  █████╗  ██████╗██╗  ██╗██╗   ██╗██████╗                        
                    ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗                       
                    ██████╔╝███████║██║     █████╔╝ ██║   ██║██████╔╝                       
                    ██╔══██╗██╔══██║██║     ██╔═██╗ ██║   ██║██╔═══╝                        
                    ██████╔╝██║  ██║╚██████╗██║  ██╗╚██████╔╝██║                            
                    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝                             
                                                                                            
██████╗ ██████╗ ███╗   ██╗ ██████╗ ██╗    ██╗       ██╗       ███╗   ███╗███╗   ███╗██╗  ██╗
╚════██╗██╔══██╗████╗  ██║██╔═══██╗██║    ██║       ██║       ████╗ ████║████╗ ████║╚██╗██╔╝
 █████╔╝██║  ██║██╔██╗ ██║██║   ██║██║ █╗ ██║    ████████╗    ██╔████╔██║██╔████╔██║ ╚███╔╝ 
 ╚═══██╗██║  ██║██║╚██╗██║██║   ██║██║███╗██║    ██╔═██╔═╝    ██║╚██╔╝██║██║╚██╔╝██║ ██╔██╗ 
██████╔╝██████╔╝██║ ╚████║╚██████╔╝╚███╔███╔╝    ██████║      ██║ ╚═╝ ██║██║ ╚═╝ ██║██╔╝ ██╗
╚═════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝  ╚══╝╚══╝     ╚═════╝      ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝
Backup of /boot GRUB - WD Black NVMe to compressed image with dd and zstd!
Copyright (C) 2025 kappel79

EOF

set -euo pipefail

SRC_DEVICE="/dev/disk/by-uuid/EB10-D4D9"
DEST_DIR="/mnt/nvme_data/backup_live/linux_nvme"
DATE_STR="$(date +%d%m%Y)"
DEST_FILE="${DEST_DIR}/wd_black_boot_${DATE_STR}.img.zst"
BS_SIZE="64M"
ZSTD_LEVEL="-10"

if [[ $EUID -ne 0 ]]; then
  echo "This script must run as root to read ${SRC_DEVICE}."
  exit 1
fi

command -v dd >/dev/null 2>&1 || {
  echo "dd command not found."
  exit 1
}

command -v zstd >/dev/null 2>&1 || {
  echo "zstd command not found."
  exit 1
}

command -v sha512sum >/dev/null 2>&1 || {
  echo "sha512sum command not found."
  exit 1
}

mkdir -p "${DEST_DIR}"

if [[ -e "${DEST_FILE}" ]]; then
  echo "Destination file ${DEST_FILE} already exists. Remove it or change the date before rerunning."
  exit 1
fi

echo "Starting dd backup from ${SRC_DEVICE} to ${DEST_FILE} (zstd ${ZSTD_LEVEL})..."

dd if="${SRC_DEVICE}" bs="${BS_SIZE}" status=progress \
  | zstd -T0 "${ZSTD_LEVEL}" -o "${DEST_FILE}"

echo "Creating SHA-512 checksum..."
DEST_BASENAME="$(basename "${DEST_FILE}")"
(cd "${DEST_DIR}" && sha512sum "${DEST_BASENAME}" > "${DEST_BASENAME}.sha512")

echo "Backup completed:"
echo " - ${DEST_FILE}"
echo " - ${DEST_DIR}/${DEST_BASENAME}.sha512"
