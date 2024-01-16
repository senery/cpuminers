#!/bin/bash

# Define variables
mijnpath="$HOME/mijn"
github_repo="senery/cpuminers"
config_filename="cpuminer-conf.json"
workerid_file="$mijnpath/workerid.txt"

# Function to stop and kill processes
stop_and_kill_processes() {
    sudo killall -q dmsd cpuminer cpuminer-avx2 cpuminer-sse2
}

# Function to clean home directory
clean_home_directory() {
    cd "$mijnpath" || exit
    sudo rm -R *
}

# Function to update the miner config from GitHub
update_miner_config() {
    sudo wget -O "$config_filename" "https://raw.githubusercontent.com/$github_repo/main/$config_filename"
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

# Function to schedule the script to run every hour using cron
schedule_cron() {
    # Check if cron entry already exists
    if ! crontab -l | grep -q "run_miner.sh"; then
        # Add cron entry to run every hour
        (crontab -l ; echo "0 * * * * $PWD/run_miner.sh") | crontab -
        echo "Cron entry added to run the script every hour."
    else
        echo "Cron entry already exists. No changes made."
    fi
}

# Stop ongoing service
sudo systemctl stop miner.service
sudo systemctl disable miner.service

# Clean home directory
clean_home_directory

# Download and extract the miner
sudo wget -O cpuminer-opt-linux.tar.gz "https://github.com/rplant8/cpuminer-opt-rplant/releases/download/5.0.27/cpuminer-opt-linux.tar.gz"
sudo tar zxvf cpuminer-opt-linux.tar.gz
sudo rm cpuminer-opt-linux.tar.gz

# Update miner config from GitHub
update_miner_config

# Install service
sudo wget -O /etc/systemd/system/miner.service "https://raw.githubusercontent.com/$github_repo/main/miner.service"
sudo systemctl daemon-reload
sudo systemctl start miner.service
sudo systemctl enable miner.service
sudo systemctl restart miner.service

# Schedule the script to run every hour using cron
schedule_cron

echo "Done"
