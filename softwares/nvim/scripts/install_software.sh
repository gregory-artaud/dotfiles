#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

# Prerequisites
sudo apt install -y ninja-build gettext cmake unzip curl

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage

./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version

# Expose nvim
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
