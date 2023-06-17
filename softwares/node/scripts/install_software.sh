#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo apt install curl 

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

source ~/.profile

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install node
