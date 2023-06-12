#!/bin/bash

help()
{
    echo "Usage: ./dotfiles.sh [ -p | --pull ]
               [ -h | --help  ]"
}

help_and_error()
{
    help
    exit 2
}

SHORT=p::,h
LONG=pull::,help
OPTS=$(getopt -a -n dotfiles --options $SHORT --longoptions $LONG -- "$@")

if [[ $? -gt 0 ]] then
    help_and_error
fi

eval set -- "$OPTS"

PULL_OPTS=-1
while :
do
  case "$1" in
    -p | --pull )
      PULL_OPTS="$2"
      shift 2
      ;;
    -h | --help )
      help
      exit 0
      ;;
    --)
      shift;
      break
      ;;
    *)
      echo "Unexpected option: $1"
      help_and_error
      ;;
  esac
done
