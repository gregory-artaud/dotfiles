#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo apt install curl 

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

source ~/.profile

nvm install node
