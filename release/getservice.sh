#!/bin/bash

# Constants
HOME_PATH="$HOME/SERVICE"
GITHUB_REPO="senery/cpuminers"
USE_SERVICE=$(curl https://raw.githubusercontent.com/senery/cpuminers/main/release/update.me)
DOWNLOAD_FILE=""
DOWNLOAD_FILENAME=""
DOWNLOAD_CFG_FILE=""
DOWNLOAD_CFG_FILENAME="cpuminer-conf.json"

download_service(){
    wget -O "$DOWNLOAD_FILENAME" "$DOWNLOAD_FILE"
    sudo tar zxvf "$DOWNLOAD_FILENAME" -C "$HOME_PATH"
    wget -O "$DOWNLOAD_CFG_FILENAME" "$DOWNLOAD_CFG_FILE"
}

if [ "$USE_SERVICE" != "0" ]; then
    if [ "$USE_SERVICE" == "1" ]; then
        # SRB
        DOWNLOAD_FILENAME="SRBMiner-Multi-2-4-6-Linux.tar.xz"
        DOWNLOAD_FILE="https://github.com/doktor83/SRBMiner-Multi/releases/download/2.4.6/SRBMiner-Multi-2-4-6-Linux.tar.xz"
        DOWNLOAD_CFG_FILE=""
    fi
    if [ "$USE_SERVICE" == "2" ]; then
        # cpuminropt
        DOWNLOAD_FILE="https://github.com/doktor83/SRBMiner-Multi/releases/download/2.4.6/SRBMiner-Multi-2-4-6-Linux.tar.xz"
        DOWNLOAD_CFG_FILE="https://raw.githubusercontent.com/senery/cpuminers/main/release/cpuminer-conf.json"
    fi
fi
download_service()