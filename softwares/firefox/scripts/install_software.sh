#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo snap remove --purge firefox

# Add mozilla repository
sudo add-apt-repository ppa:mozillateam/ppa

# Gives priority over snap
echo "Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1

Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 200" > /etc/apt/preferences.d/mozillateamppa

# Enable automatic updates
. /etc/os-release
echo "Unattended-Upgrade::Allowed-Origins:: \"LP-PPA-mozillateam:${VERSION_CODENAME}\";"\
    > /etc/apt/apt.conf.d/51unattended-upgrades-firefox

sudo apt update -y && sudo apt upgrade -y

sudo apt install firefox
