#!/bin/bash

apt update -y && apt upgrade -y
apt install -y wireguard qrencode


NET_FORWARD="net.ipv4.ip_forward=1"
sysctl -w  ${NET_FORWARD}
sed -i "s:#${NET_FORWARD}:${NET_FORWARD}:" /etc/sysctl.conf

cd /etc/wireguard

umask 077

SERVER_PRIVKEY=$( wg genkey )
SERVER_PUBKEY=$( echo $SERVER_PRIVKEY | wg pubkey )

echo $SERVER_PUBKEY > ./server_public.key
echo $SERVER_PRIVKEY > ./server_private.key

ENDPOINT="$(curl -s ifconfig.me.):51820"
echo $ENDPOINT > ./endpoint.var

SERVER_IP="10.22.0.1/24"
echo $SERVER_IP | grep -o -E '([0-9]+\.){3}' > ./vpn_subnet.var

DNS="1.1.1.1"
echo $DNS > ./dns.var

echo 1 > ./last_used_ip.var

WAN_INTERFACE_NAME="eth0"

echo $WAN_INTERFACE_NAME > ./wan_interface_name.var

cat ./endpoint.var | sed -e "s/:/ /" | while read SERVER_EXTERNAL_IP SERVER_EXTERNAL_PORT
do
cat > ./wg0.conf.def << EOF
[Interface]
Address = $SERVER_IP
SaveConfig = true
PrivateKey = $SERVER_PRIVKEY
ListenPort = $SERVER_EXTERNAL_PORT
PostUp = ufw route allow in on wg0 out on eth0
PostUp = iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on eth0
PreDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF
done

cp -f ./wg0.conf.def ./wg0.conf

echo -e '\nnet.ipv4.ip_forward=1\n' >> filename

ufw allow 51820/udp
ufw allow OpenSSH
ufw disable
ufw enable

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
