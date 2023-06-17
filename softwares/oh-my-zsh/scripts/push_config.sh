#!/bin/bash

config_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/../config

cp $config_path/zshrc $HOME/.zshrc

chsh -s $(which zsh)
