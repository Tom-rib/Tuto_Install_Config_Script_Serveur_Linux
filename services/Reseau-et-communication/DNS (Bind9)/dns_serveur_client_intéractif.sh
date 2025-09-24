#!/bin/bash
# ==================================================
# Script interactif d'installation et configuration DNS (Bind9)
# Serveur / Client / Test / Désinstallation
# Gère une ou deux interfaces (LAN + WAN ou LAN + LAN)
# ==================================================

if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être lancé avec sudo !"
    exit 1
fi

# ---------------------------
# Fonctions
# ---------------------------

installer_serveur() {
    echo "[INFO] Installation de Bind9..."
    apt update && apt install -y bind9 bind9-utils bind9-dnsutils netfilter-persistent iptables-persistent

    echo "[CONFIG] Base réseau (ex: 192.168.136) :"
    read -p "Base IP LAN (sans le dernier octet, ex: 192.168.136) : " BASE_IP
    read -p "Dernier octet du serveur DNS (ex: 253) : " DNS_X
    DNS_IP="$BASE_IP.$DNS_X"

    read -p "Nom de domaine (ex: tutoserveurs.local) : " DOMAIN
    read -p "Nom du serveur DNS (ex: serveur1) : " SERVER_NAME
    read -p "IP de la passerelle/routeur (dernier octet ex: 254) : " GW_X
    GATEWAY_IP="$BASE_IP.$GW_X"

    # Sauvegarde
    cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak 2>/dev/null || true

    # Déclaration des zones
    cat > /etc/bind/named.conf.local <<EOF
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
    cat > /etc/bind/db.$DOMAIN <<EOF
\$TTL    604800
@       IN      SOA     ns1.$DOMAIN. admin.$DOMAIN. (
                        2         ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL

; Serveur DNS
@       IN      NS      ns1.$DOMAIN.
ns1     IN      A       $DNS_IP
$SERVER_NAME IN A       $GATEWAY_IP
EOF

    # Zone inverse
    REV_IP="$(echo $DNS_IP | awk -F. '{print $3"."$2"."$1}')"
    cat > /etc/bind/db.$REV_IP <<EOF
\$TTL    604800
@       IN      SOA     ns1.$DOMAIN. admin.$DOMAIN. (
                        1         ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL

; Serveur DNS
@       IN      NS      ns1.$DOMAIN.

; Résolution inverse
$(echo $DNS_IP | awk -F. '{print $4}') IN PTR ns1.$DOMAIN.
$(echo $GATEWAY_IP | awk -F. '{print $4}') IN PTR $SERVER_NAME.$DOMAIN.
EOF

    # Config forwarding ?
    echo "[INFO] Voulez-vous configurer une deuxième interface WAN/LAN ? (y/n)"
    read CHOIX2
    if [ "$CHOIX2" == "y" ]; then
        read -p "Nom interface secondaire : " SEC_IF
        echo "[TYPE] Cette interface est WAN ou LAN ?"
        read -p "(wan/lan) : " TYPE_IF

        if [ "$TYPE_IF" == "wan" ]; then
            echo "[INFO] Ajout des DNS publics (8.8.8.8 / 1.1.1.1)..."
            cat >> /etc/bind/named.conf.options <<EOF

options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { any; };
    forwarders {
        8.8.8.8;
        1.1.1.1;
    };
    dnssec-validation auto;
};
EOF

            # Activer forwarding
            sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
            sysctl -p

            # NAT
            iptables -t nat -A POSTROUTING -o $SEC_IF -j MASQUERADE
            iptables -A INPUT -p udp --dport 53 -j ACCEPT
            iptables -A INPUT -p tcp --dport 53 -j ACCEPT
            netfilter-persistent save
        fi
    fi

    # Vérification
    named-checkconf
    named-checkzone $DOMAIN /etc/bind/db.$DOMAIN
    named-checkzone $REV_IP.in-addr.arpa /etc/bind/db.$REV_IP

    systemctl restart bind9
    systemctl enable bind9

    echo "[OK] Serveur DNS installé et configuré."
}

installer_client() {
    echo "[INFO] Installation client DNS..."
    apt update && apt install -y bind9-dnsutils
    read -p "IP du serveur DNS : " DNS_IP
    read -p "Nom de domaine local (ex: tutoserveurs.local) : " DOMAIN

    echo "nameserver $DNS_IP" > /etc/resolv.conf
    echo "search $DOMAIN" >> /etc/resolv.conf

    echo "[OK] Client DNS configuré."
}

tester_dns() {
    read -p "IP du serveur DNS à tester : " DNS_IP
    read -p "Nom de domaine à tester : " DOMAIN
    dig @$DNS_IP $DOMAIN
    nslookup $DOMAIN $DNS_IP
}

desinstaller_dns() {
    echo "[INFO] Suppression DNS..."
    apt remove -y bind9 bind9-utils bind9-dnsutils
    apt autoremove -y
}

# ---------------------------
# Menu principal
# ---------------------------

while true; do
    echo "=============================="
    echo "    SCRIPT DNS INTERACTIF"
    echo "=============================="
    echo "1) Installer serveur DNS"
    echo "2) Installer client DNS"
    echo "3) Tester DNS"
    echo "4) Désinstaller DNS"
    echo "0) Quitter"
    echo "=============================="
    read -p "Choix : " CHOIX

    case $CHOIX in
        1) installer_serveur ;;
        2) installer_client ;;
        3) tester_dns ;;
        4) desinstaller_dns ;;
        0) exit 0 ;;
        *) echo "[ERREUR] Choix invalide !" ;;
    esac
done
