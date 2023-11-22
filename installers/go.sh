#!/bin/bash

# https://go.dev/dl/
# https://go.dev/doc/install

GO_VERSION="1.20"
DOWNLOAD_DIR=`mktemp -d`
wget -o- "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -P $DOWNLOAD_DIR
rm -rf /usr/local/go && tar -C /usr/local -xzf $DOWNLOAD_DIR/go$GO_VERSION.linux-amd64.tar.gz

# Install gopls language server
# By default this will go to $HOME/go/bin
go install -v golang.org/x/tools/gopls@latest



