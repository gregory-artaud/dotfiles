#!/bin/bash

config_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/../config

mkdir -p $HOME/.config/nvim
cp -rf $config_path/* $HOME/.config/nvim/
