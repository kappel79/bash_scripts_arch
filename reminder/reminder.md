
        /////////////////
       ////NUDGE APP////
      /////////////////

Copyright (C) 2025 kappel79


A lightweight shell-based reminder utility that waits for a specified duration and then triggers a notification (for example, a sound, message, or terminal alert). Ideal for quick, ad-hoc reminders without needing a full scheduling tool.

Nudge: A gentle, subtle reminder (often used in behavioral science).


Installation


Make the script executable:

chmod +x reminder.sh

Usage

Run the script with a time duration:

./reminder.sh <time>


Supported time formats include seconds, minutes, or combinations supported by the sleep command (e.g., 150s, 5m, 2m34s).

Examples
# --- Usage examples ---
./reminder.sh 2m34s
./reminder.sh 150s
./reminder.sh 5m
# ----------------------

Requirements

Linux or macOS environment with POSIX shell

sleep command available

Optional: notification tools depending on your implementation (e.g., notify-send on Linux)

Notes

This utility is intended for short, interactive reminders rather than long-term scheduling. For more advanced scheduling, consider cron, at, or workflow automation tools.

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