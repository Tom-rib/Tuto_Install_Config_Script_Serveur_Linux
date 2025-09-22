#!/bin/bash
# Script d'installation serveur DHCP
INTERFACE=${1:-eth0}
SUBNET=${2:-192.168.15.0}
NETMASK=${3:-255.255.255.0}
RANGE_START=${4:-192.168.15.100}
RANGE_END=${5:-192.168.15.200}
ROUTER=${6:-192.168.15.254}
DNS=${7:-192.168.15.253}
DOMAIN=${8:-tutoserveurs.local}

echo "[INFO] Mise à jour des paquets..."
sudo apt update

echo "[INFO] Installation du serveur DHCP..."
sudo apt install isc-dhcp-server -y

echo "[INFO] Configuration de l'interface $INTERFACE..."
sudo sed -i "s|^INTERFACESv4=.*|INTERFACESv4=\"$INTERFACE\"|" /etc/default/isc-dhcp-server

echo "[INFO] Création du fichier de configuration dhcpd.conf..."
sudo tee /etc/dhcp/dhcpd.conf > /dev/null <<EOL
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet $SUBNET netmask $NETMASK {
    range $RANGE_START $RANGE_END;
    option routers $ROUTER;
    option domain-name-servers $DNS;
    option domain-name "$DOMAIN";
}
EOL

echo "[INFO] Redémarrage du serveur DHCP..."
sudo systemctl restart isc-dhcp-server

echo "[INFO] Statut du serveur DHCP :"
systemctl status isc-dhcp-server | head -n 20
