#!/bin/bash
# ==================================================
# Script de test DNS pour client Linux
# Usage: sudo ./test_dns_client.sh [DNS_IP] [DOMAIN] [SERVER_NAME] [CLIENT_IP]
# Exemple: sudo ./test_dns_client.sh 192.168.136.253 tutoserveurs.local serveur1 192.168.136.10
# ==================================================

set -e

# ---------------------------
# Variables avec valeurs par défaut
# ---------------------------
DNS_IP=${1:-192.168.136.253}      # IP du serveur DNS
DOMAIN=${2:-tutoserveurs.local}   # Nom de domaine
SERVER_NAME=${3:-serveur1}        # Nom du serveur
CLIENT_IP=${4:-192.168.136.140}    # IP du client

# ---------------------------
# Début du script
# ---------------------------

echo "[TEST] Vérification du DNS configuré dans resolv.conf..."
RESOLV_DNS=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}')
echo "DNS actuel: $RESOLV_DNS"

if [[ "$RESOLV_DNS" == "$DNS_IP" ]]; then
    echo "[OK] Le client utilise le DNS correct: $DNS_IP"
else
    echo "[WARN] Le client n'utilise pas le DNS attendu ($DNS_IP). Actuel: $RESOLV_DNS"
fi

echo
echo "[TEST] Résolution directe du serveur principal..."
dig @$DNS_IP $SERVER_NAME.$DOMAIN +short

echo
echo "[TEST] Résolution inverse du serveur principal..."
dig @$DNS_IP -x $CLIENT_IP +short

echo
echo "[TEST] Résolution d’un domaine externe (via forwarder)..."
dig @$DNS_IP www.google.com +short

echo
echo "[INFO] Tests DNS client terminés !"
