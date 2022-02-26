#!/bin/bash
workerid=${RANDOM:0:5}   
sudo curl -s -L https://raw.githubusercontent.com/senery/cpuminers/main/run_miner.sh | bash -s  $workerid
echo $workerid is running
#sudo systemctl status miner.service
sudo reboot
