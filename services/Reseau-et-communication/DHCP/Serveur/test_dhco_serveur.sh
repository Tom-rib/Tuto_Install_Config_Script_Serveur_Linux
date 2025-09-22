#!/bin/bash
# Script de test serveur DHCP

echo "[TEST] Vérification du statut du serveur DHCP..."
systemctl status isc-dhcp-server | head -n 20

echo "[TEST] Redémarrage du serveur DHCP..."
sudo systemctl restart isc-dhcp-server
sleep 2

echo "[TEST] Vérification du statut après redémarrage..."
systemctl status isc-dhcp-server | head -n 20

echo "[TEST] Vérification des baux distribués aux clients..."
if [ -f /var/lib/dhcp/dhcpd.leases ]; then
    tail -n 20 /var/lib/dhcp/dhcpd.leases
else
    echo "[WARN] Fichier dhcpd.leases introuvable"
fi

echo "[TEST] Vérification des logs DHCP..."
sudo journalctl -u isc-dhcp-server --since "5 minutes ago" | tail -n 20
