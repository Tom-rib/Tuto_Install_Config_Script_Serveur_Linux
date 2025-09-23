#!/bin/bash
# ==================================================
# Script d'installation et configuration DNS client
# Usage: sudo ./install_dns_client.sh [INTERFACE] [DNS_IP] [DOMAIN]
# Exemple: sudo ./install_dns_client.sh eth0 192.168.136.253 tutoserveurs.local
# ==================================================

set -e

# ---------------------------
# Variables avec valeurs par défaut
# ---------------------------
INTERFACE=${1:-ens33}              # Interface réseau
DNS_IP=${2:-192.168.136.253}      # IP du serveur DNS
DOMAIN=${3:-tutoserveurs.local}   # Domaine local

# ---------------------------
# Début du script
# ---------------------------

echo "[INFO] Mise à jour des paquets..."
sudo apt update -y

echo "[INFO] Installation des utilitaires DNS..."
sudo apt install -y bind9-dnsutils

echo "[INFO] Configuration du DNS pour l'interface $INTERFACE..."

# Détection du type d'interface pour configurer /etc/network/interfaces
if grep -q "$INTERFACE" /etc/network/interfaces; then
    echo "[INFO] Configuration statique dans /etc/network/interfaces..."
    sudo sed -i "/iface $INTERFACE inet/c\iface $INTERFACE inet static\n    dns-nameservers $DNS_IP\n    dns-search $DOMAIN" /etc/network/interfaces
else
    echo "[INFO] Ajout du DNS via resolv.conf (méthode temporaire)..."
    sudo bash -c "echo 'nameserver $DNS_IP' > /etc/resolv.conf"
    sudo bash -c "echo 'search $DOMAIN' >> /etc/resolv.conf"
fi

echo "[INFO] Redémarrage du service réseau..."
sudo systemctl restart networking

echo "[INFO] Installation et configuration DNS client terminées !"
echo "Vous pouvez maintenant tester la résolution DNS avec dig ou nslookup, par exemple :"
echo "dig @$DNS_IP $DOMAIN"
