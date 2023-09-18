#!/bin/bash

# https://github.com/nvm-sh/nvm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh > /dev/null 2>&1 | bash

echo "Try: nvm install --lts"
echo "Try: nvm use --lts"