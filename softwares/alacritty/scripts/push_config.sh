#!/bin/bash

config_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/../config

cp $config_path/alacritty.yml $HOME/.alacritty.yml
