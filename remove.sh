# We read from the input parameter the name of the client
read -p "Are you sure you want to remove WireGuard?: [y/n]" CONFIRM
if ["y" -ne $CONFIRM ]
  then
  echo "[#]Exiting"
  exit 1;
fi

echo "# Removing"

wg-quick down wg0
systemctl stop wg-quick@wg0
systemctl disable wg-quick@wg0

apt autoremove -y wireguard wireguard-dkms wireguard-tools
apt update -y

rm -rf /etc/wireguard

echo "# Removed"
