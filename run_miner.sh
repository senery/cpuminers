#!/bin/bash 
echo kill the old bitches
#workerid=${RANDOM:0:2}  

sudo killall dmsd -q

sudo killall cpuminer -q

sudo killall cpuminer-avx2 -q

sudo killall cpuminer-sse2 -q

sudo systemctl stop miner.service

sudo systemctl disable miner.service

#  maak miner dir en download de miner

cd ~

sudo mkdir miner 

cd miner

# dir legen

sudo rm -r *

sudo wget https://github.com/rplant8/cpuminer-opt-rplant/releases/download/5.0.24/cpuminer-opt-linux.tar.gz

sudo tar zxvf cpuminer-opt-linux.tar.gz

sudo killall cpuminer-sse2

cd /home/senery/miner

# nu de minerconfig ophalen en random name zetten

sudo rm -r cpuminer-conf.json

sudo systemctl stop miner.service

sudo systemctl disable miner.service

# miner cfg

#workerid=${RANDOM:0:5}
workerid=${1}
cd /home/senery/miner

sudo wget https://raw.githubusercontent.com/senery/Ratjetoe/main/cpuminer-conf.json 

sudo sed -i s/workerid/$workerid/ /home/senery/miner/cpuminer-conf.json

# service

cd /etc/systemd/system

sudo rm -r miner.service

sudo wget https://raw.githubusercontent.com/senery/Ratjetoe/main/miner.service

# create cli for 

#clicmd=   "ExecStart=/bin/bash -c -e  '/home/senery/miner/cpuminer-sse2 --conf=/home/senery/miner/cpuminer-conf.json'"

sudo systemctl daemon-reload

sudo systemctl start miner.service  

sudo systemctl enable miner.service  

sudo reboot 
