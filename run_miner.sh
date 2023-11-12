#!/bin/bash 
# kill the old bitches
if [ -z "$1" ];
then  workerid=${RANDOM:0:5};echo "workerid set ";echo $workerid;
else  workerid=$1;echo "workerid set as ";echo $workerid;
fi

#unload old runbin
sudo killall dmsd -q
sudo killall cpuminer -q
sudo killall cpuminer-avx2 -q
sudo killall cpuminer-sse2 -q

#stop ongoing service
sudo systemctl stop miner.service
sudo systemctl disable miner.service

#clean home dir
sudo mkdir /home/postvak_jo
cd /home/postvak_jo
sudo rm -R *

# miner dl en ex
sudo wget https://github.com/rplant8/cpuminer-opt-rplant/releases/download/5.0.27/cpuminer-opt-linux.tar.gz
sudo tar zxvf cpuminer-opt-linux.tar.gz
#cd /home/postvak_jo/cpuminer

# nu de default miner config bijwerken etc
sudo rm -r cpuminer-conf.json
sudo wget https://raw.githubusercontent.com/senery/cpuminers/main/cpuminer-conf.json
sudo sed -i s/workerid/$workerid/ cpuminer-conf.json

# instell service
cd /etc/systemd/system
sudo rm -r /etc/systemd/system/miner.service
sudo wget  https://raw.githubusercontent.com/senery/cpuminers/main/miner.service 
sudo systemctl daemon-reload
sudo systemctl start miner.service  
sudo systemctl enable miner.service
sudo systemctl daemon-reload
sudo systemctl restart miner.service

echo "done"
