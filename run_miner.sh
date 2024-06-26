#!/bin/bash

# Get the current user and working directory
current_user=$(whoami)
current_working_directory=$(pwd)

# Define variables
mijnpath="$HOME"
github_repo="senery/cpuminers"
config_filename="cpuminer-conf.json"
workerid_file="$mijnpath/workerid.txt"
miner_service_file="$mijnpath/miner.service"

# Function to stop and kill processes
stop_and_kill_processes() {
    sudo killall -q dmsd cpuminer cpuminer-avx2 cpuminer-sse2
}

# Function to clean home directory
clean_home_directory() {
    if [ -d "$mijnpath" ]; then
        cd "$mijnpath" || exit
        sudo rm -R *
    fi
}

# Function to update the miner config from GitHub
update_miner_config() {
    sudo wget -O "$config_filename" "https://raw.githubusercontent.com/$github_repo/main/$config_filename"
    # Ensure the directory for workerid_file exists
    mkdir -p "$(dirname "$workerid_file")"
    # Prompt user for a new worker ID if it doesn't exist
    if [ ! -f "$workerid_file" ]; then
        read -p "Enter worker ID for the first time: " workerid
        echo "$workerid" > "$workerid_file"
    else
        # Read worker ID from file
        workerid=$(cat "$workerid_file")
    fi
    # Replace workerid in config
    sudo sed -i "s/workerid/$workerid/" "$config_filename"
}

# Function to check if the miner service is running
is_miner_service_running() {
    sudo systemctl is-active --quiet miner.service
}

# Function to display detailed status if miner service is not running
show_service_status() {
    sudo systemctl status miner.service
}

# Function to install/update miner.service
install_miner_service() {
    if [ -f "/etc/systemd/system/miner.service" ]; then
        sudo systemctl daemon-reload
        sudo systemctl start miner.service
        sudo systemctl enable miner.service
        sudo systemctl restart miner.service
    else
        # Download the updated miner.service file
        sudo wget -O "/etc/systemd/system/miner.service" "https://raw.githubusercontent.com/$github_repo/main/miner.service"
        # Update user and working directory dynamically
        sudo sed -i "s/User=root/User=$current_user/" "/etc/systemd/system/miner.service"
        sudo sed -i "s|WorkingDirectory=/home|WorkingDirectory=$current_working_directory|" "/etc/systemd/system/miner.service"
        sudo systemctl daemon-reload
        sudo systemctl start miner.service
        sudo systemctl enable miner.service
        sudo systemctl restart miner.service
    fi
}

# Stop ongoing service if it exists
if is_miner_service_running; then
    sudo systemctl stop miner.service
    sudo systemctl disable miner.service
fi

# Clean home directory if it exists
clean_home_directory

# Download and extract the miner
sudo wget -O cpuminer-opt-linux.tar.gz "https://github.com/rplant8/cpuminer-opt-rplant/releases/download/5.0.27/cpuminer-opt-linux.tar.gz"
sudo tar zxvf cpuminer-opt-linux.tar.gz
sudo rm cpuminer-opt-linux.tar.gz

# Update miner config from GitHub
update_miner_config

# Install/update miner.service
install_miner_service

# Check if the miner service is running after the script
if is_miner_service_running; then
    echo "Miner service is running."
else
    echo "Miner service is not running. Showing service details:"
    show_service_status
fi

echo "Done"
