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
export NVM_VERSION=0.39.5
export NVIM_VERSION=v0.10.2

# Install some common utils
sudo apt-get update

# Note: Any chars after \ including whitespace will break the multiline string.
# libfuse2 is a library required to run app images on > 22.04
sudo apt-get install -y \
    build-essential \
    curl \
    libfuse2 \
    fd-find \
    ripgrep \
    fzf     \
    git \
    zsh \

# Install oh my zsh
if [ ! -d $HOME/.oh-my-zsh ]; then 
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Sets default shell to zsh (should be done by the oh my zsh installer)
    # chsh -s $(which zsh)
fi

# ========================================
# General terminal setup
# ========================================

# Bash aliases, .bash_aliases are sources by default in .bashrc
# in most linux distributions
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SHELL_DIR=$(realpath "$SCRIPT_DIR/../shell")
ln -rsf $SHELL_DIR/aliases.sh ~/.bash_aliases
ln -rsf $SHELL_DIR/profile.sh ~/.bashprofile
ln -rsf $SHELL_DIR/profile.sh ~/.zshprofile

# ZSH setup
ln -rsf $SHELL_DIR/zshrc.zsh ~/.zshrc

# Some basic git stuff
git config --global user.name "Jake Dern"
git config --global user.email jakedern@yahoo.com
git config --global core.editor "nvim"

mkdir -p ~/repos
mkdir -p ~/bin

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

# Best way to install zellij is through cargo
if ! command -v cargo &> /dev/null; then
    echo "cargo not found, installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash
    rustup update
else
    echo "cargo already installed"
fi

# ========================================
# Neovim setup
# ========================================
NVIM_DIR=$(realpath "$SCRIPT_DIR/../neovim/nvim")

if ! command -v nvim &> /dev/null; then
    echo "neovim not found"
    TEMP=$(mktemp -d)

    pushd $TEMP
    # Note -L option is required to follow re-directs. Otherwise you get an empty file
    # -O option saves the file to it's default name "nvim.appimage"
    curl -LO https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage
    mv nvim.appimage ~/bin/nvim
    popd

    chmod +x ~/bin/nvim
else
    echo "neovim already installed"
fi

# Link neovim config to nvim dir
mkdir -p ~/.config
ln -rsf $NVIM_DIR ~/.config

# ========================================
# Install bin scripts
# ========================================
BIN_DIR=$(realpath "$SCRIPT_DIR/../bin")
BIN_SCRIPTS=$(find $BIN_DIR -maxdepth 1 -type f)
# Link all scripts in bin dir
for script in $BIN_SCRIPTS; do
    name=$(basename "$script" | echo zellij-sessionizer.sh | sed -e "s/\.sh//")
    ln -rsf $script ~/bin/$name
done


# ========================================
# Zellij setup 
# ========================================
ZELLIJ_DIR=$(realpath "$SCRIPT_DIR/../zellij")
if ! command -v zellij &> /dev/null; then
    echo "zellij not found"
    cargo install --locked zellij
else
    echo "zellij already installed"
fi

# Install zellij config file
ln -rsf $ZELLIJ_DIR ~/.config

