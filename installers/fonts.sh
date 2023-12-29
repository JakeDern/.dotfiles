#!/bin/bash

# First have to clone the nerd-fonts repo
CLONE_DIR=$(mktemp -d)
pushd $CLONE_DIR
git clone https://github.com/ryanoasis/nerd-fonts.git

# Next install fonts using their install script

./install.sh JetBrainsMono

# Next set up the font to be used in the terminal. For windows terminal you have to install it in windows:
#
# https://support.microsoft.com/en-us/office/add-a-font-b7c5f17c-4426-4b53-967f-455339c564c1
# https://github.com/ryanoasis/nerd-fonts/releases

