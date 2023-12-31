#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Install zellij config file
mkdir -p ~/.config/zellij
ln -rsf $SCRIPT_DIR/config.kdl ~/.config/zellij/config.kdl # r for relative path, s for symbolic, f for force

# Install zellij layout file
mkdir -p ~/.config/zellij/layouts
ln -rsf $SCRIPT_DIR/default_layout.kdl ~/.config/zellij/layouts/default.kdl # r for relative path, s for symbolic, f for force

