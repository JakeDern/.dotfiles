#!/bin/bash

set -e # Exit after first error
set -m # Enable "job control", not on by default in zsh

# If we're running this from zshell then we need a bunch
# of stuff that's normally added in bashrc and bashprofile
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# Version constants, probably take a look around and update these
NVM_VERSION=0.40.1
NVIM_VERSION=v0.12.0
STOW_VERSION=2.4.1

# Install common utils
# Note: Any chars after \ including whitespace will break the multiline string.
#
# libfuse2 - A library required to run app images on > 22.04
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    curl \
    libfuse2 \
    git \
    zsh \
    stow \

# Install oh my zsh
if [ ! -d $HOME/.oh-my-zsh ]; then 
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Sets default shell to zsh (should be done by the oh my zsh installer)
    # chsh -s $(which zsh)
fi

# ========================================
# Stow 
# ========================================

# Need version at least 2.4.1 which has some bugfixes
# in order to handle directories properly. If the default version through 
# apt-get is ever 2.4.1 I can rename directories to dot-config instead of .config

# Bash aliases, .bash_aliases are sources by default in .bashrc
# in most linux distributions
ROOT=$(git rev-parse --show-toplevel)

# Symlink everything into home directory. --dotfiles
# will replace any file starting with "dot-*" with ".*"
mkdir -p $HOME/repos $HOME/bin $HOME/.config $HOME/.local/share
stow --dotfiles -d $ROOT/stow -t $HOME shell claude zellij zed neovim

# ========================================
# FZF
# ========================================

FZF_DIR=$HOME/.local/share/fzf
if ! command -v cargo &> /dev/null; then
    git clone https://github.com/junegunn/fzf.git $FZF_DIR

    # Installation script takes care of everything including updating
    # bash/zsh profile, enabling keybinds, and setting up completions
    $FZF_DIR/install
fi

# ========================================
# Rust toolchain and programs
# ========================================

# Best way to install zellij is through cargo
if ! command -v cargo &> /dev/null; then
    echo "cargo not found, installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash
    rustup update
else
    echo "cargo already installed"
fi

# Zellij
ZELLIJ_DIR=$(realpath "$ROOT/zellij")
if ! command -v zellij &> /dev/null; then
    echo "zellij not found"
    cargo install --locked zellij
else
    echo "zellij already installed"
fi

# ripgrep versions are typically pretty old when installed
# via package managers. May as well do it from source.
if ! command -v rg &> /dev/null; then
    echo "Ripgrep not found"
    cargo install ripgrep
else
    echo "Ripgrep already installed"
fi

# fd-find - Better find written in rust
if ! command -v fdfind &> /dev/null; then
    echo "fd not found"
    cargo install fd-find
else
    echo "fd-find already installed"
fi

# bat - For previewing files
if ! command -v bat &> /dev/null; then
    echo "bat not found"
    cargo install --locked bat
else
    echo "bat already installed"
fi

# ========================================
# Miscellaneous dependencies
# ========================================

# nvm doens't show up without sourcing this script. This is done in
# bashrc, but it doesn't stick in the subshell for scripts
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
if ! command -v nvm &> /dev/null; then
    echo "nvm not found, installing..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh 2>&1 | bash
    # Load nvm again after install
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
else
    echo "nvm already installed"
fi

# ========================================
# Neovim setup
# ========================================
if ! command -v nvim &> /dev/null; then
    echo "neovim not found"
    TEMP=$(mktemp -d)

    pushd $TEMP
    # Note -L option is required to follow re-directs. Otherwise you get an empty file
    # -O option saves the file to it's default name "nvim.appimage"
    curl -LO https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage
    mv nvim-linux-x86_64.appimage ~/bin/nvim
    popd

    chmod +x ~/bin/nvim
else
    echo "neovim already installed"
fi

