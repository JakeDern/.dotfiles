#!/bin/bash

root_folders="$HOME/repos $HOME/repos/monitoring/projects"

function attach_session() {
    local session_root=$1
    local session_name=$(basename "$session_root" | tr . _)
    cd $session_root
    if ! zellij list-sessions --short | grep -wxq "$session_name" ; then
        zellij --session $session_name --layout ~/.config/zellij/layouts/project_layout.kdl options --default-mode locked
    else
        zellij attach $session_name
    fi
}

quit_option="=== Quit sessionizer ==="
last_session=""
while true; do
    selected_option=$( (echo $quit_option && echo $HOME && find $root_folders -mindepth 1 -maxdepth 1 -type d) | fzf --reverse)

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

