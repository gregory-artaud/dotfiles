#!/usr/bin/env bash
set -euo pipefail
# Import only variables that exist in the current X11 session.
variables=()
for name in DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP; do
    [[ -v $name ]] && variables+=("$name")
done
if ((${#variables[@]})); then
    systemctl --user import-environment "${variables[@]}"
    dbus-update-activation-environment --systemd "${variables[@]}"
fi
systemctl --user start gisland.service
