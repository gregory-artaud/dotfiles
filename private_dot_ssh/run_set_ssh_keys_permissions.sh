#!/bin/sh

FILES="$HOME/.ssh/id_github $HOME/.ssh/id_github.pub"

for FILE in $FILES; do
    if [ -f "$FILE" ]; then
        if [ "$(stat -c %a "$FILE")" != "600" ]; then
            chmod 600 "$FILE"
        fi
    fi
done

