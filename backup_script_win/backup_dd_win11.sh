#!/usr/bin/env bash

cat << "EOF"

::::::::::::::'##:::::'##:'####:'##::: ##:'########:::'#######::'##:::::'##::'######::::'########::'########::::::::::::::::::::'##::::
:::::::::::::: ##:'##: ##:. ##:: ###:: ##: ##.... ##:'##.... ##: ##:'##: ##:'##... ##::: ##.... ##: ##.... ##:::::::::::::::::::. ##:::
'#####:'#####: ##: ##: ##:: ##:: ####: ##: ##:::: ##: ##:::: ##: ##: ##: ##: ##:::..:::: ##:::: ##: ##:::: ##::::::::::::::::::::. ##::
.....::.....:: ##: ##: ##:: ##:: ## ## ##: ##:::: ##: ##:::: ##: ##: ##: ##:. ######:::: ##:::: ##: ##:::: ##:'#######:'#######:::. ##:
'#####:'#####: ##: ##: ##:: ##:: ##. ####: ##:::: ##: ##:::: ##: ##: ##: ##::..... ##::: ##:::: ##: ##:::: ##:........:........::: ##::
.....::.....:: ##: ##: ##:: ##:: ##:. ###: ##:::: ##: ##:::: ##: ##: ##: ##:'##::: ##::: ##:::: ##: ##:::: ##:::::::::::::::::::: ##:::
::::::::::::::. ###. ###::'####: ##::. ##: ########::. #######::. ###. ###::. ######:::: ########:: ########:::::::::::::::::::: ##::::
:::::::::::::::...::...:::....::..::::..::........::::.......::::...::...::::......:::::........:::........:::::::::::::::::::::..:::::
  ++ 640k memory detected ++++ 640k memory detected ++++ 640k memory detected ++++ 640k memory detected ++++ 640k memory detected ++
  ++ 640k memory detected ++++ 640k memory detected ++++ 640k memory detected ++++ 640k memory detected ++++ 640k memory detected ++
                              ============================================================================
                              ==      ==============================  =====  ===========  ====  =======  =
                              =  ====  =============================   ===   ===========  ====  =======  =
                              =  ====  ==  =================  ======  =   =  ===========  ====  =======  =
                              ==  ======    ==   ==  =   ==    =====  == ==  ==   ======  ====  =    ==  =
                              ====  =====  ==  =  =    =  ==  ======  =====  =  =  =====  ====  =  =  =  =
                              ======  ===  =====  =  =======  ======  =====  =     =====  ====  =  =  =  =
                              =  ====  ==  ===    =  =======  ======  =====  =  ========  ====  =    =====
                              =  ====  ==  ==  =  =  =======  ======  =====  =  =  =====   ==   =  ====  =
                              ==      ===   ==    =  =======   =====  =====  ==   =======      ==  ====  =
                              ============================================================================
++ FATAL ERROR: Missing or invalid MSDOS.SYS entry ++ 
UninstallDir=C:\ 
WinDir=C:\WIN95 
WinBootDir=C:\WIN95 
HostWinBootDrv=/BOOT  
                          Backup Win11 NVMe - Samsung 9100Pro PCIe5 NTFS to compressed image with dd and zstd.
                                                      Copyright (C) 2025 kappel79

EOF

#exit 0 

set -euo pipefail

#Get the disk by the ID:
#ls -l /dev/disk/by-id/ | grep nvme0n1


SRC_DEVICE="/dev/disk/by-id/nvme-eui.002538a55141934d"
DEST_DIR="/mnt/nvme_data/backup_live/windows_nvme"
DATE_STR="$(date +%d%m%Y)"
DEST_FILE="${DEST_DIR}/win11_nvme_${DATE_STR}.img.zst"
BS_SIZE="4M"
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
