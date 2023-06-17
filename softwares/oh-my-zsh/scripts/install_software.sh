#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo apt install -y zsh curl

# Installs oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
