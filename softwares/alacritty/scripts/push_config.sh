#!/bin/bash

config_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/../config

cp $config_path/alacritty.toml $HOME/.alacritty.toml

echo $HOME
mkdir -p $HOME/.local/share/fonts/NerdFonts/
cp $config_path/ttf/*.ttf $HOME/.local/share/fonts/NerdFonts/
fc-cache -f -v
