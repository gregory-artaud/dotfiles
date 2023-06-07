#!/bin/bash

source ./utils/select_option.sh

softwares_paths=($(ls -d $(pwd)"/softwares/"*))
PUSH_SCRIPT_PATH=/scripts/push_config.sh

softwares_names=()
gather_softwares_names ()
{
    for path in "${softwares_paths[@]}"
    do
        softwares_names+=($(echo $path | rev | cut -d'/' -f 1 | rev))
    done
}

IGNORE=0
INSTALL=1
CONFIG=2
INSTALL_AND_CONFIG=3
options=(
    "Ignore"
    "Install"
    "Configure"
    "Install and configure"
)
softwares_cmd=()
ask_install_or_config ()
{
    for software in "${softwares_names[@]}"
    do
        echo "What do you want to do with:" $software "?"
        select_option "${options[@]}"
        softwares_cmd+=($?)
    done
}
    
install_software ()
{
    echo "Installing" $1
}

pull_config ()
{
    # TODO
    echo "Pulling config of" $1
}

push_config ()
{
    echo "Pushing config of" ${softwares_names[$1]}
    bash ${softwares_paths[$1]}$PUSH_SCRIPT_PATH
}

execute_commands ()
{
    for i in "${!softwares_cmd[@]}"
    do
        cmd=${softwares_cmd[$i]}
        if (( $cmd == $INSTALL || $cmd == $INSTALL_AND_CONFIG ))
        then
            install_software "${softwares_names[$i]}"
        fi
        if (( $cmd == $CONFIG || $cmd == $INSTALL_AND_CONFIG ))
        then
            push_config $i
        fi
    done
}

gather_softwares_names
ask_install_or_config
execute_commands
