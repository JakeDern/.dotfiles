#!/bin/bash

# https://github.com/nvm-sh/nvm

if ! command -v nvm &>/dev/null; then
	echo "Installing nvm"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
fi

echo "Try: nvm install --lts"
echo "Try: nvm use --lts"