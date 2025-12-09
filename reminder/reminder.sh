#!/usr/bin/env bash


cat << "EOF"

        /////////////////
       ////NUDGE APP////
      /////////////////

Copyright (C) 2025 kappel79

EOF

set -euo pipefail

usage() {
  printf 'Usage: %s <time> (e.g., 2m34s or 150s)\n' "$0" >&2
}

# --- Usage example ---
# ./reminder.sh 2m34s
# ./reminder.sh 150s
# ./reminder.sh 5m
# ----------------------

main() {
  # Check if the user provided a time
  if [ $# -ne 1 ]; then
    usage
    exit 1
  fi

  input=$1

  # Convert input like 2m34s or 150s into total seconds
  if [[ "$input" =~ ^([0-9]+)m([0-9]+)s$ ]]; then
    total=$(( ${BASH_REMATCH[1]} * 60 + ${BASH_REMATCH[2]} ))
  elif [[ "$input" =~ ^([0-9]+)m$ ]]; then
    total=$(( ${BASH_REMATCH[1]} * 60 ))
  elif [[ "$input" =~ ^([0-9]+)s$ ]]; then
    total=${BASH_REMATCH[1]}
  else
    printf 'Invalid format. Use something like 2m34s, 5m, or 45s.\n' >&2
    exit 1
  fi

  if [ "$total" -le 0 ]; then
    printf 'Time must be greater than zero.\n' >&2
    exit 1
  fi

  printf '⏳ Countdown started for %s...\n\n' "$input"

  # Countdown loop
  for ((i=total; i>0; i--)); do
    min=$((i / 60))
    sec=$((i % 60))
    printf "\rTime remaining: %02d:%02d" "$min" "$sec"
    sleep 1
  done

  printf '\n\nRUN! 🏃💨\n'
}

main "$@"
# Optional: sound or desktop notification
# printf '\a'
# notify-send "RUN!"

