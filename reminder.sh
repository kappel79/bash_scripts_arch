#!/bin/bash

# --- Usage example ---
# ./reminder.sh 2m34s
# ./reminder.sh 150s
# ./reminder.sh 5m
# ----------------------

# Check if the user provided a time
if [ -z "$1" ]; then
  echo "Usage: $0 <time> (e.g., 2m34s or 150s)"
  exit 1
fi

# Convert input like 2m34s or 150s into total seconds
if [[ "$1" =~ ^([0-9]+)m([0-9]+)s$ ]]; then
  total=$(( ${BASH_REMATCH[1]} * 60 + ${BASH_REMATCH[2]} ))
elif [[ "$1" =~ ^([0-9]+)m$ ]]; then
  total=$(( ${BASH_REMATCH[1]} * 60 ))
elif [[ "$1" =~ ^([0-9]+)s$ ]]; then
  total=${BASH_REMATCH[1]}
else
  echo "Invalid format. Use something like 2m34s, 5m, or 45s."
  exit 1
fi

echo "⏳ Countdown started for $1..."
echo

# Countdown loop
for ((i=total; i>0; i--)); do
  min=$((i / 60))
  sec=$((i % 60))
  printf "\rTime remaining: %02d:%02d" "$min" "$sec"
  sleep 1
done

echo -e "\n\nRUN! 🏃💨"
# Optional: sound or desktop notification
# printf '\a'
# notify-send "RUN!"

