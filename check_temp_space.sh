#!/usr/bin/env bash
# check_temp_space.sh

paths=(
  /tmp
  /var/tmp
  /var/cache/pacman/pkg
  /var/log
  "$HOME/.cache"
  "$HOME/.local/share/Trash"
  "$HOME/.cache/thumbnails"
)

echo "== Disk usage =="
df -h
echo

echo "== Suspect temp/cache dirs =="
for p in "${paths[@]}"; do
  [ -e "$p" ] || continue
  du -sh "$p"
done 2>/dev/null | sort -h

echo
echo "== systemd journal =="
journalctl --disk-usage

