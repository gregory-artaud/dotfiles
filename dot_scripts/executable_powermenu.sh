#!/usr/bin/env bash
# CMDs
uptime="`uptime -p | sed -e 's/up //g'`"
host=`hostname`

shutdown='󰐥'
reboot='󰜉'
lock='󰌾'
logout='󰍃'
yes=' Yes'
no=' No'

rofi_cmd() {
	rofi -dmenu \
		-p "$host" \
		-mesg "Uptime: $uptime" \
		-theme $HOME/.config/rofi/powermenu.rasi
}

run_rofi() {
	echo -e "$lock\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		poweroff
        ;;
    $reboot)
		reboot
        ;;
    $lock)
        hyprlock
        ;;
    $logout)
		swaymsg exit
        ;;
esac
