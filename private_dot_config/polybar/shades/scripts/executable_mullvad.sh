#!/usr/bin/env bash

output=$(mullvad status)

# if the output doesn't contains "Connected", then we're disconnected
if [[ $output != *"Connected"* ]]; then
    echo "  not connected to Mullvad"
    exit 0
fi

server_name=$(grep -oP '\w+-\w+-(wg|ovpn)-\d+' <<< "$output")
server_ip=$(grep -oP '(?<=IPv4: ).*$' <<< "$output")

echo "  $server_name | $server_ip"
