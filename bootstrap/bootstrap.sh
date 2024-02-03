#!/bin/bash

# Version constants, probably take a look around and update these
NVM_VERSION=0.39.5
NVIM_VERSION=v0.9.5

# Install some common utils
sudo apt-get update

# Note: Any chars after \ including whitespace will break the multiline string
sudo apt-get install -y \
    build-essential \
    curl \
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

# Some basic git stuff
git config --global user.name "Jake Dern"
git config --global user.email jakedern@yahoo.com
git config --global core.editor "nvim"

mkdir -p ~/repos
mkdir -p ~/bin

# nvm doens't show up without sourcing this script. This is done in
# bashrc, but it doesn't stick in the subshell for scripts
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
if ! command -v nvm &> /dev/null; then
    echo "nvm not found, installing..."
    # Install nvm. We need latest node for various neovim plugins
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh 2>&1 | bash
else
    echo "nvm already installed"
fi

# Best way to install zellij is through cargo
if ! command -v cargo &> /dev/null; then
    echo "cargo not found, installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rustup update
else
    echo "cargo already installed"
fi

# ========================================
# Neovim setup
# ========================================
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
NVIM_DIR=$(realpath "$SCRIPT_DIR/../neovim/nvim")

if ! command -v nvim &> /dev/null; then
    echo "neovim not found"
    curl -O https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim.appimage --output-dir ~/bin
    mv ~/bin/nvim.appimage ~/bin/nvim
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
# General terminal setup
# ========================================

# Bash aliases, .bash_aliases are sources by default in .bashrc
# in most linux distributions
BASH_DIR=$(realpath "$SCRIPT_DIR/../bash")
ln -rsf $BASH_DIR/bash_aliases.sh ~/.bash_aliases
ln -rsf $BASH_DIR/bashprofile.sh ~/.bashprofile

# ZSH setup
ZSH_DIR=$(realpath "$SCRIPT_DIR/../zsh")
ln -rsf $ZSH_DIR/zshrc.zsh ~/.zshrc
ln -rsf $ZSH_DIR/zsh_profile.zsh ~/.zsh_profile

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

