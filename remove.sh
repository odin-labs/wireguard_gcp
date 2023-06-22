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

yes | apt autoremove wireguard wireguard-dkms wireguard-tools
yes | apt update

rm -rf /etc/wireguard

echo "# Removed"
