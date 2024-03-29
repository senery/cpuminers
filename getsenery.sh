#!/bin/bash

# Constants
HOME_PATH="$HOME/SERVICE"
GITHUB_REPO="senery/cpuminers"
CONFIG_FILENAME="cpuminer-conf.json"
WORKERID_FILE="$HOME_PATH/workerid.txt"
SERVICE_FILE="$HOME_PATH/miner.service"
EXCLUDE_FILE="$HOME_PATH/getsenery.sh"  # Add the name of the file or directory you want to exclude
LOG_FILE="$HOME_PATH/miner_installation.log"

# Function to stop and kill processes
stop_and_kill_processes() {
    sudo killall -q dmsd cpuminer cpuminer-avx2 cpuminer-sse2
}

# Function to clean home directory, excluding a specific file or directory
clean_home_directory() {
    if [ -d "$HOME_PATH" ]; then
        cd "$HOME_PATH" || exit
        sudo find . -maxdepth 1 -type f -not -name "$EXCLUDE_FILE" -exec rm {} \;
    fi
}

# Function to update the miner config from GitHub
update_miner_config() {
    sudo wget -O "$CONFIG_FILENAME" "https://raw.githubusercontent.com/$GITHUB_REPO/main/$CONFIG_FILENAME"
    # Ensure the directory for workerid_file exists
    mkdir -p "$(dirname "$WORKERID_FILE")"
    # Prompt user for a new worker ID if it doesn't exist
    if [ ! -f "$WORKERID_FILE" ]; then
        read -p "Enter worker ID for the first time: " workerid
        echo "$workerid" > "$WORKERID_FILE"
    else
        # Read worker ID from file
        workerid=$(cat "$WORKERID_FILE")
    fi
    # Replace workerid in config
    sudo sed -i "s/workerid/$workerid/" "$CONFIG_FILENAME"
}

# Function to check if the miner service is running
is_miner_service_running() {
    sudo systemctl is-active --quiet miner.service
}

# Function to display detailed status if miner service is not running
show_service_status() {
    sudo systemctl status miner.service
}

# Function to log messages
log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Redirect output to a log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Stop ongoing service if it exists
if is_miner_service_running; then
    sudo systemctl stop miner.service
    sudo systemctl disable miner.service
fi

# Clean home directory, excluding a specific file or directory
clean_home_directory

# Download and extract the miner
sudo wget -O cpuminer-opt-linux.tar.gz "https://github.com/rplant8/cpuminer-opt-rplant/releases/download/5.0.27/cpuminer-opt-linux.tar.gz"
sudo tar zxvf cpuminer-opt-linux.tar.gz
sudo rm cpuminer-opt-linux.tar.gz

# Update miner config from GitHub
update_miner_config

# Download or update the service file
if [ -f "/etc/systemd/system/miner.service" ]; then
    MINER_SERVICE_FILE="/etc/systemd/system/miner.service"
else
    MINER_SERVICE_FILE="$SERVICE_FILE"
fi

sudo wget -O "$MINER_SERVICE_FILE" "https://raw.githubusercontent.com/$GITHUB_REPO/main/miner.service"
sudo sed -i "s/User=root/User=$(whoami)/" "$MINER_SERVICE_FILE"
sudo sed -i "s|WorkingDirectory=/home|WorkingDirectory=$PWD|" "$MINER_SERVICE_FILE"
sudo systemctl daemon-reload
sudo systemctl start miner.service
sudo systemctl enable miner.service
sudo systemctl restart miner.service

# Check if the miner service is running after the script
if is_miner_service_running; then
    log "Miner service is running."
else
    log "Miner service is not running. Showing service details:"
    show_service_status
fi

log "Script completed"
