#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo apt install -y tmux

tmux kill-server
