#!/bin/bash
# Script d'installation client DHCP
# Usage: ./dhcp_client.sh [interface]
# Par défaut, l'interface est eth0 (changer pour la votre ip a pour savoir l'interface)
# Crée le script: sudo nano dhcp_client.sh
#
# Rendre le script exécutable: sudo chmod +x dhcp_client.sh
#
# Exécuter le script : sudo ./dhcp_client.sh

INTERFACE=${1:-eth0}

echo "[INFO] Mise à jour des paquets..."
sudo apt update

echo "[INFO] Installation du client DHCP..."
sudo apt install isc-dhcp-client -y

echo "[INFO] Configuration de l'interface $INTERFACE pour DHCP..."
sudo tee /etc/network/interfaces > /dev/null <<EOL
auto $INTERFACE
iface $INTERFACE inet dhcp
EOL

echo "[INFO] Redémarrage de l'interface réseau..."
sudo systemctl restart networking

echo "[INFO] Obtention d'une adresse IP..."
sudo dhclient -v $INTERFACE

echo "[INFO] Adresse IP actuelle :"
ip addr show $INTERFACE
