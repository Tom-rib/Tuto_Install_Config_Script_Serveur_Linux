#!/bin/bash
# ==================================================
# Script de test pour Bind9
# Réutilisable avec variables
# ==================================================

set -e

# ---------------------------
# Variables à modifier
# ---------------------------
DOMAIN="tutoserveurs.local"      # Nom de domaine
DNS_IP="192.168.136.253"        # IP du serveur DNS
GATEWAY_IP="192.168.136.254"    # Passerelle / serveur principal
CLIENT1_IP="192.168.136.140"     # Exemple client 1
CLIENT2_IP="192.168.136.141"     # Exemple client 2
CLIENT1_NAME="client1"          # Nom client 1
CLIENT2_NAME="client2"          # Nom client 2
SERVER_NAME="serveur1"          # Nom du serveur principal

# ---------------------------
# Début du script
# ---------------------------
echo "[TEST] Vérification du statut du service DNS..."
sudo systemctl status named --no-pager

echo
echo "[TEST] Vérification du fichier resolv.conf..."
cat /etc/resolv.conf

echo
echo "[TEST] Résolution directe du serveur principal..."
dig @$DNS_IP $SERVER_NAME.$DOMAIN

echo
echo "[TEST] Résolution inverse du serveur principal..."
dig @$DNS_IP -x $GATEWAY_IP

echo
echo "[TEST] Résolution directe du client1..."
dig @$DNS_IP $CLIENT1_NAME.$DOMAIN

echo
echo "[TEST] Résolution inverse du client1..."
dig @$DNS_IP -x $CLIENT1_IP

echo
echo "[TEST] Résolution directe du client2..."
dig @$DNS_IP $CLIENT2_NAME.$DOMAIN

echo
echo "[TEST] Résolution inverse du client2..."
dig @$DNS_IP -x $CLIENT2_IP

echo
echo "[TEST] Test NS lookup du domaine..."
dig @$DNS_IP NS $DOMAIN

echo
echo "[INFO] Tests terminés !"
