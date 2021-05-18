#!/bin/bash
#sudo su
#sudo add-apt-repository -y ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install -y wireguard
sudo apt-get remove -y dnsmasq
#echo "DNSStubListener=no" >> /etc/systemd/resolved.conf
#systemctl restart systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
#echo nameserver 1.1.1.1 > /etc/resolv.conf
#echo nameserver 8.8.8.8 >> /etc/resolv.conf
sudo modprobe wireguard
sudo modprobe iptable_nat
sudo modprobe ip6table_nat
echo "wireguard" | sudo tee /etc/modules-load.d/wireguard.conf
echo "iptable_nat" | sudo tee /etc/modules-load.d/iptable_nat.conf
echo "ip6table_nat" | sudo tee /etc/modules-load.d/ip6table_nat.conf
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo mkdir /data

sudo docker create \
    --name subspace \
    --restart always \
    --network host \
    --cap-add NET_ADMIN \
    --volume /data:/data \
    --env SUBSPACE_HTTP_HOST="wg.any-time.online" \
    --env SUBSPACE_HTTP_INSECURE="true" \
    --env SUBSPACE_LETSENCRYPT="false" \
    --env SUBSPACE_NAMESERVER="1.1.1.1,8.8.8.8" \
    --env SUBSPACE_LISTENPORT="51820" \
    --env SUBSPACE_IPV4_POOL="10.218.90.0/23" \
    --env SUBSPACE_IPV4_PREF="10.218.90." \
    --env SUBSPACE_IPV6_POOL="fd00::10:90:0/64" \
    --env SUBSPACE_IPV4_GW="10.218.90.1" \
    --env SUBSPACE_IPV6_PREF="fd00::10:90:" \
    --env SUBSPACE_IPV6_GW="fd00::10:90:1" \
    --env SUBSPACE_IPV6_NAT_ENABLED=0 \
    subspacecommunity/subspace:latest

sudo docker start subspace
