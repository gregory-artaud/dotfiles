#!/bin/bash

config_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/../config

getent group docker || sudo groupadd docker
sudo usermod -aG docker $USER
