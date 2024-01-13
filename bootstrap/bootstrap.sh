#!/bin/bash

# Version constants, probably take a look around and update these
#
NVM_VERSION=0.39.5

# Install some common utils
#
# sudo apt-get update

# Note: Any chars after \ including whitespace will break the multiline string
#
# sudo apt-get install -y \
#     build-essential \
#     curl \
#     fd-find \
#     ripgrep \
#     fzf     \
#     git \

# Some basc git stuff
git config --global user.name "Jake Dern"
git config --global user.email jakedern@yahoo.com

mkdir -p ~/repos
mkdir -p ~/work
mkdir -p ~/personal

# nvm doens't show up without sourcing this script. This is done in
# bashrc, but it doesn't stick in the subshell for scripts
#
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
if ! command -v nvm &> /dev/null; then
    echo "nvm not found"
    nvm --version
    # Install nvm. We need latest node for various neovim plugins
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh 2>&1 | bash
fi

# Best way to install zellij is through cargo
if ! command -v cargo &> /dev/null; then
    echo "cargo not found"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rustup update
fi

# ========================================
# Neovim setup
# ========================================
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
NVIM_DIR=$(realpath "$SCRIPT_DIR/../neovim/nvim")

# Link neovim config to nvim dir
mkdir -p ~/.config
ln -rsf $NVIM_DIR ~/.config

# ========================================
# General terminal setup
# ========================================
TERMINAL_DIR=$(realpath "$SCRIPT_DIR/../terminal")

# Bash aliases, .bash_aliases are sources by default in .bashrc
# in most linux distributions
ln -rsf $TERMINAL_DIR/bash_aliases.sh ~/.bash_aliases

# ========================================
# Zellij setup 
# ========================================
if ! command -v zellij &> /dev/null; then
    echo "zellij not found"
    cargo install --locked zellij
fi

# Install zellij config file
mkdir -p ~/.config/zellij
ln -rsf $TERMINAL_DIR/config.kdl ~/.config/zellij/config.kdl

# Install zellij layout file
mkdir -p ~/.config/zellij/layouts
ln -rsf $TERMINAL_DIR/default_layout.kdl ~/.config/zellij/layouts/default.kdl

