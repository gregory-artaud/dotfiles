#!/bin/bash

echo "Pull config template"

config_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/../config

# Here your instruction to pull the configuration