#!/bin/bash

config_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/../config

cp $HOME/.gitconfig $config_path/gitconfig 
