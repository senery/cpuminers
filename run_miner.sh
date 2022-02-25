#!/bin/bash 
echo kill the old bitches
#workerid=${RANDOM:0:2}   

sudo killall dmsd -q
sudo killall cpuminer -q
sudo killall cpuminer-avx2 -q
sudo killall cpuminer-sse2 -q
sudo systemctl stop miner.service
sudo systemctl disable miner.service
#getlatest
cd /home/senery
sudo rm -r cpuminers
sudo git clone https://github.com/senery/cpuminers.git
#  maak miner dir en download de miner
echo miner install
cd ~
sudo mkdir miner 
cd miner
# dir legen
sudo rm -r *
sudo wget https://github.com/rplant8/cpuminer-opt-rplant/releases/download/5.0.27/cpuminer-opt-linux.tar.gz
sudo tar zxvf cpuminer-opt-linux.tar.gz
sudo killall cpuminer-sse2
cd /home/senery/miner
# nu de minerconfig ophalen en random name zetten
echo config
sudo rm -r cpuminer-conf.json
sudo systemctl stop miner.service
sudo systemctl disable miner.service
sudo rm -r /etc/systemd/system/miner.service

#workerid=${RANDOM:0:5}
#workerid=${1}
workerid=$1

sudo cp /home/senery/cpuminers/cpuminer-conf.json /home/senery/miner/cpuminer-conf.json
sudo cp /home/senery/cpuminers/miner.service /etc/systemd/system/miner.service
# service
cd /etc/systemd/system
sudo sed -i s/workerid/$workerid/ /home/senery/miner/cpuminer-conf.json
sudo systemctl daemon-reload
sudo systemctl start miner.service  
sudo systemctl enable miner.service  
echo done

