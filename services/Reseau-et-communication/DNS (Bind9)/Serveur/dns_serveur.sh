#!/bin/bash
# ==================================================
# Script automatique d'installation et de configuration Bind9
# Version réutilisable avec variables
# ==================================================

set -e

# ---------------------------
# Variables à modifier
# ---------------------------
DOMAIN="tutoserveurs.local"      # Nom de domaine
DNS_IP="192.168.136.253"        # IP du serveur DNS
GATEWAY_IP="192.168.136.254"    # Passerelle / serveur principal
CLIENT1_IP="192.168.136.140"     # Exemple client 1
CLIENT2_IP="192.168.136.11"     # Exemple client 2
CLIENT1_NAME="client1"          # Nom client 1
CLIENT2_NAME="client2"          # Nom client 2
SERVER_NAME="serveur1"          # Nom du serveur principal

# ---------------------------
# Début du script
# ---------------------------
echo "[INFO] Mise à jour des paquets..."
sudo apt update -y

echo "[INFO] Installation de Bind9 et utilitaires..."
sudo apt install -y bind9 bind9-utils bind9-dnsutils

echo "[INFO] Configuration des zones DNS..."

# Sauvegarde avant modification
sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak

# Déclaration des zones
sudo tee /etc/bind/named.conf.local > /dev/null <<EOF
zone "$DOMAIN" {
    type master;
    file "/etc/bind/db.$DOMAIN";
};

zone "$(echo $DNS_IP | awk -F. '{print $3"."$2"."$1}').in-addr.arpa" {
    type master;
    file "/etc/bind/db.$(echo $DNS_IP | awk -F. '{print $3"."$2"."$1}')";
};
EOF

# Zone directe
sudo tee /etc/bind/db.$DOMAIN > /dev/null <<EOF
\$TTL    604800
@       IN      SOA     ns1.$DOMAIN. admin.$DOMAIN. (
                        2         ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL

; Serveurs DNS
@       IN      NS      ns1.$DOMAIN.

; Enregistrements A
ns1     IN      A       $DNS_IP
$SERVER_NAME IN A       $GATEWAY_IP
$CLIENT1_NAME IN A      $CLIENT1_IP
$CLIENT2_NAME IN A      $CLIENT2_IP
EOF

# Zone inverse
REV_IP="$(echo $DNS_IP | awk -F. '{print $3"."$2"."$1}')"  # Inversion pour zone inverse
sudo tee /etc/bind/db.$REV_IP > /dev/null <<EOF
\$TTL    604800
@       IN      SOA     ns1.$DOMAIN. admin.$DOMAIN. (
                        1         ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL

; Serveurs DNS
@       IN      NS      ns1.$DOMAIN.

; Résolution inverse
$(echo $DNS_IP | awk -F. '{print $4}')   IN PTR ns1.$DOMAIN.
$(echo $GATEWAY_IP | awk -F. '{print $4}') IN PTR $SERVER_NAME.$DOMAIN.
$(echo $CLIENT1_IP | awk -F. '{print $4}') IN PTR $CLIENT1_NAME.$DOMAIN.
$(echo $CLIENT2_IP | awk -F. '{print $4}') IN PTR $CLIENT2_NAME.$DOMAIN.
EOF

echo "[INFO] Vérification des fichiers de configuration..."
sudo named-checkconf
sudo named-checkzone $DOMAIN /etc/bind/db.$DOMAIN
sudo named-checkzone $REV_IP.in-addr.arpa /etc/bind/db.$REV_IP

echo "[INFO] Redémarrage de Bind9..."
sudo systemctl restart bind9
sudo systemctl enable bind9

echo "[INFO] Installation et configuration terminées !"
