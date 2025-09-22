#!/bin/bash
# Script de test client DHCP
# Usage: sudo nano test_dhcp_client.sh [interface]
#chmod +x tests_client.sh
#./tests_client.sh eth0
INTERFACE=${1:-eth0}

echo "[TEST] Vérification de l'adresse IP actuelle pour $INTERFACE..."
ip addr show $INTERFACE

echo "[TEST] Obtention d'une nouvelle adresse IP via DHCP..."
sudo dhclient -v $INTERFACE

echo "[TEST] Adresse IP après demande DHCP :"
ip addr show $INTERFACE

echo "[TEST] Vérification des baux DHCP reçus..."
if [ -f /var/lib/dhcp/dhclient.leases ]; then
    tail -n 20 /var/lib/dhcp/dhclient.leases
else
    echo "[WARN] Fichier dhclient.leases introuvable"
fi
