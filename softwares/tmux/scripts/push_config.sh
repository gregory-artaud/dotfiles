#!/bin/bash

config_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/../config

cp $config_path/tmux.conf $HOME/.tmux.conf
cp $config_path/tmux.conf.local $HOME/.tmux.conf.local
