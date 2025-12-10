#!/usr/bin/env bash

cat << "EOF"

 █████╗ ██████╗  ██████╗██╗  ██╗     █████╗ ██╗    ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗   
██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔══██╗██║    ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝   
███████║██████╔╝██║     ███████║    ███████║██║    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝    
██╔══██║██╔══██╗██║     ██╔══██║    ██╔══██║██║    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗    
██║  ██║██║  ██║╚██████╗██║  ██║    ██║  ██║██║    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗   
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝   
                                                                                            
                ██████╗  █████╗  ██████╗██╗  ██╗██╗   ██╗██████╗         ██╗                
                ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗       ██╔╝                
                ██████╔╝███████║██║     █████╔╝ ██║   ██║██████╔╝      ██╔╝                 
                ██╔══██╗██╔══██║██║     ██╔═██╗ ██║   ██║██╔═══╝      ██╔╝                  
                ██████╔╝██║  ██║╚██████╗██║  ██╗╚██████╔╝██║         ██╔╝                   
                ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝         ╚═╝                    
                                                                                            
██████╗ ██████╗ ███╗   ██╗ ██████╗ ██╗    ██╗       ██╗       ███╗   ███╗███╗   ███╗██╗  ██╗
╚════██╗██╔══██╗████╗  ██║██╔═══██╗██║    ██║       ██║       ████╗ ████║████╗ ████║╚██╗██╔╝
 █████╔╝██║  ██║██╔██╗ ██║██║   ██║██║ █╗ ██║    ████████╗    ██╔████╔██║██╔████╔██║ ╚███╔╝ 
 ╚═══██╗██║  ██║██║╚██╗██║██║   ██║██║███╗██║    ██╔═██╔═╝    ██║╚██╔╝██║██║╚██╔╝██║ ██╔██╗ 
██████╔╝██████╔╝██║ ╚████║╚██████╔╝╚███╔███╔╝    ██████║      ██║ ╚═╝ ██║██║ ╚═╝ ██║██╔╝ ██╗
╚═════╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝  ╚══╝╚══╝     ╚═════╝      ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝
                                                                                            
EOF

set -euo pipefail

# Back up the root filesystem to /mnt/nvme_data/backup_live using rsync snapshots.

readonly SRC="/"
readonly DEST_BASE="/mnt/nvme_data/backup_live/rsync"
readonly TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
readonly TARGET="${DEST_BASE}/${TIMESTAMP}"
readonly LATEST_LINK="${DEST_BASE}/latest"

EXCLUDES=(
  "/dev/*"
  "/proc/*"
  "/sys/*"
  "/tmp/*"
  "/run/*"
  "/mnt/nvme_data/backup_live/*"
  "/media/*"
  "/lost+found"
  "/swapfile"
)

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_root() {
  [[ "$(id -u)" -eq 0 ]] || die "run as root so file ownership and ACLs are preserved"
}

ensure_destination() {
  mkdir -p "${DEST_BASE}"
  local mountpoint
  mountpoint="$(findmnt -rno TARGET --target "${DEST_BASE}" 2>/dev/null)" || \
    die "${DEST_BASE} is not on a mounted filesystem"
  [[ "${mountpoint}" != "/" ]] || \
    die "${DEST_BASE} currently lives on /; mount the backup disk before running"
}

build_rsync_excludes() {
  local opts=()
  for path in "${EXCLUDES[@]}"; do
    opts+=(--exclude="${path}")
  done
  printf '%s\n' "${opts[@]}"
}

main() {
  require_root
  ensure_destination
  mkdir -p "${TARGET}"

  RSYNC_OPTS=(
    --archive
    --acls
    --xattrs
    --hard-links
    --numeric-ids
    --delete
    --delete-excluded
    --human-readable
    --info=progress2
    --one-file-system
  )

  if [[ -d "${LATEST_LINK}" ]]; then
    RSYNC_OPTS+=(--link-dest="${LATEST_LINK}")
  fi

  mapfile -t EXCLUDE_OPTS < <(build_rsync_excludes)

  trap 'rm -rf "${TARGET}"' INT TERM ERR

  ionice -c2 -n7 nice -n 19 \
    rsync "${RSYNC_OPTS[@]}" "${EXCLUDE_OPTS[@]}" "${SRC}" "${TARGET}"

  ln -sfn "${TARGET}" "${LATEST_LINK}"
  trap - INT TERM ERR

  printf 'Backup complete: %s\n' "${TARGET}"
}

main "$@"
