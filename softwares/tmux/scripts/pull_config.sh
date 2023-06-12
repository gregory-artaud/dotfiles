#!/bin/bash

config_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/../config

cp $HOME/.tmux.conf $config_path/tmux.conf 
cp $HOME/.tmux.conf.local $config_path/tmux.conf.local 
