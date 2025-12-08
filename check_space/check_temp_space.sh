#!/usr/bin/env bash
# check_temp_space.sh

set -euo pipefail

# Refuse to run if any of the monitored paths look like options.
sanitize_path() {
  case "$1" in
    -*)
      echo "Refusing to inspect path beginning with '-' to avoid option injection: $1" >&2
      return 1
      ;;
  esac
}

paths=(
  /tmp
  /var/tmp
  /var/cache/pacman/pkg
  /var/log
  "$HOME/.cache"
  "$HOME/.local/share/Trash"
  "$HOME/.cache/thumbnails"
)

printf '== Disk usage ==\n'
df -h
printf '\n'

printf '== Suspect temp/cache dirs ==\n'
for p in "${paths[@]}"; do
  sanitize_path "$p" || continue
  [ -e "$p" ] || continue
  du -sh -- "$p"
done 2>/dev/null | sort -h

printf '\n== systemd journal ==\n'
journalctl --disk-usage

