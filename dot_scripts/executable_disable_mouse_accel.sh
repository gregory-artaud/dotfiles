#!/usr/bin/env bash

# Disable mouse acceleration by forcing a flat profile on libinput devices.
# Skips touchpads, trackpoints, tablets, and pens.

set -euo pipefail

command -v xinput >/dev/null 2>&1 || exit 0

# Give X a moment to enumerate devices on startup/reload
sleep 1

# Iterate over pointer devices and apply flat accel profile
xinput list --short \
  | awk '/pointer/ { for (i=1;i<=NF;i++) if ($i ~ /id=/) { sub("id=","",$i); print $i } }' \
  | while read -r id; do
      # Get human-readable name
      name="$(xinput list --name-only "$id" 2>/dev/null || true)"
      lname="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')"

      # Skip touchpads/trackpoints/tablets/pens
      if printf '%s' "$lname" | grep -Eq 'touchpad|trackpoint|tablet|wacom|stylus|pen'; then
        continue
      fi

      # Only apply when libinput properties exist
      if xinput list-props "$id" | grep -q "libinput Accel Profile Enabled"; then
        # Enable flat profile (Adaptive=0, Flat=1)
        xinput set-prop "$id" "libinput Accel Profile Enabled" 0 1 || true
      fi

      if xinput list-props "$id" | grep -q "libinput Accel Speed"; then
        # Keep neutral speed for consistency with flat profile
        xinput set-prop "$id" "libinput Accel Speed" 0 || true
      fi
    done

exit 0
