#!/bin/bash

cd ~/cbn/boardfarm
. ./deploy-boardfarm-nodes.sh

## for boardfarm1 172.16.1.227
#./deploy-boardfarm-nodes.sh eth0 101 144
#set -x; IFACE=eth1 create_container_eth1_static wan-shared 172.16.1.229/24 172.16.1.1; set +x

## for boardfarm2 172.16.1.221
#./deploy-boardfarm-nodes.sh eth0 101 112
#set -x; IFACE=eth1 create_container_eth1_static wan-shared 172.16.1.232/24 172.16.1.1; set +x

## for boardfarm3 172.16.1.xx
#./deploy-boardfarm-nodes.sh eth0 101 102
#set -x; IFACE=eth1 create_container_eth1_static wan-shared 172.16.1.220/24 172.16.1.1; set +x

## for boardfarm4 172.16.1.246
#./deploy-boardfarm-nodes.sh eth0 101 102
#set -x; IFACE=eth1 create_container_eth1_static wan-shared 172.16.1.247/24 172.16.1.1; set +x

## docker set ip netmask gateway by manual
#docker exec -it bft-node-eth1-wan-shared /bin/bash
## docker for boardfarm ip:172.16.1.xxx (229, 232, 220, 247)
#ifconfig eth1 172.16.1.xxx netmask 255.255.255.0 && route add default gw 172.16.1.1
## reboot start
#@reboot echo cbn | sudo -S ~/cbn/boardfarm/docker.sh

## init docker node
#sudo docker build -t bft:node bft-node
#sudo addgroup cbn docker
