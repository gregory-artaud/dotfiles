#!/bin/bash

softwares_paths=($(ls -d $(pwd)"/softwares/"*))

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
softwares_cmd=()
ask_install_or_config ()
{
    for software in "${softwares_names[@]}"
    do
        echo "Here a menu to select install / config / ignore" $software
        softwares_cmd+=(0)
    done
}
    
install_software ()
{
    echo "installing" $1
}

pull_config ()
{
    echo "pulling config of" $1
}

push_config ()
{
    echo "pushing config of" $1
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
            push_config "${softwares_names[$i]}"
        fi
    done
}

gather_softwares_names
ask_install_or_config
execute_commands
