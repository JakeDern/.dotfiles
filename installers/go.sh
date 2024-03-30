#!/bin/bash

# https://go.dev/dl/
# https://go.dev/doc/install

GO_VERSION="1.22.1"
DOWNLOAD_DIR=`mktemp -d`
wget -o- "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -P $DOWNLOAD_DIR
rm -rf /usr/local/go && tar -C /usr/local -xzf $DOWNLOAD_DIR/go${GO_VERSION}.linux-amd64.tar.gz

