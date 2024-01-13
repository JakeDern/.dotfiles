#!/bin/bash

root_folders="$HOME/projects $HOME/work $HOME/.config"

function attach_session() {
    local session_root=$1
    local session_name=$(basename "$session_root" | tr . _)
    cd $session_root
    zellij attach --create $session_name
}

quit_option="=== Quit sessionizer ==="
last_session=""
while true; do
    selected_option=$( (echo $quit_option && find $root_folders -mindepth 1 -maxdepth 1 -type d) | fzf --reverse)

    if [[ $selected_option == $quit_option ]]; then
        exit 0
    fi
    
    if [[ -z $selected_option && -z $last_session ]]; then
        exit 0
    fi

    if [[ -z $selected_option ]]; then
        attach_session $last_session
    else
        last_session=$selected_option
        attach_session $selected_option
    fi
done

