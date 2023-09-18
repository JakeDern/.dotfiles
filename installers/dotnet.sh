#!/bin/bash

# Add microsoft source
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb > /dev/null 2>&1
sudo dpkg -i packages-microsoft-prod.deb > /dev/null 2>&1
rm packages-microsoft-prod.deb > /dev/null 2>&1

# Install dotnet
sudo apt-get update \
    && sudo apt-get install -y dotnet-sdk-7.0 \
    && sudo apt-get install -y dotnet-sdk-6.0

