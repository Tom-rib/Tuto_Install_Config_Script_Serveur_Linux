#!/bin/bash
# ==============================================
# Script interactif d'installation DHCP
# Serveur / Client / Test / Désinstallation
# Gère 1 ou 2 interfaces (LAN/WAN ou LAN/LAN)
# ==============================================

# Vérifier si sudo est utilisé
if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être lancé avec sudo !"
    exit 1
fi

# ==============================
# Fonctions
# ==============================

installer_serveur() {
    echo "[INFO] Installation du serveur DHCP..."
    apt update && apt install -y isc-dhcp-server netfilter-persistent iptables-persistent

    echo "[CONFIG] Interface LAN principale :"
    read -p "Nom interface LAN (ex: ens33) : " LAN_IF

    echo "[CONFIG] Base réseau (ex: 192.168.136) :"
    read -p "Base IP (sans le dernier octet, ex: 192.168.136) : " BASE_IP

    read -p "Dernier octet routeur (ex: 254) : " ROUTER_X
    ROUTER_IP="$BASE_IP.$ROUTER_X"

    read -p "Début de plage DHCP (ex: 100) : " RANGE_START_X
    RANGE_START="$BASE_IP.$RANGE_START_X"

    read -p "Fin de plage DHCP (ex: 200) : " RANGE_END_X
    RANGE_END="$BASE_IP.$RANGE_END_X"

    echo "[CONFIG] Serveur DNS local :"
    read -p "Adresse IP du DNS (ex: $ROUTER_IP ou autre) : " DNS_IP

    read -p "Nom de domaine (ex: tutoserveurs.local) : " DOMAIN

    # Config interface DHCP
    sed -i "s|^INTERFACESv4=.*|INTERFACESv4=\"$LAN_IF\"|" /etc/default/isc-dhcp-server

    # Config DHCP
    cat > /etc/dhcp/dhcpd.conf <<EOL
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet $BASE_IP.0 netmask 255.255.255.0 {
    range $RANGE_START $RANGE_END;
    option routers $ROUTER_IP;
    option domain-name-servers $DNS_IP;
    option domain-name "$DOMAIN";
}
EOL

    echo "[INFO] Voulez-vous configurer une deuxième interface ? (y/n)"
    read CHOIX2
    if [ "$CHOIX2" == "y" ]; then
        read -p "Nom interface secondaire : " SEC_IF
        echo "[TYPE] Cette interface est WAN ou LAN ?"
        read -p "(wan/lan) : " TYPE_IF

        if [ "$TYPE_IF" == "wan" ]; then
            echo "[INFO] Configuration WAN + NAT"
            echo "nameserver 8.8.8.8" >> /etc/resolv.conf

            # Activer forwarding
            sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
            sysctl -p

            # NAT
            iptables -t nat -A POSTROUTING -o $SEC_IF -j MASQUERADE
            netfilter-persistent save

        elif [ "$TYPE_IF" == "lan" ]; then
            echo "[CONFIG] Base réseau secondaire (ex: 192.168.137) :"
            read -p "Base IP LAN2 : " BASE_IP2
            read -p "Dernier octet routeur LAN2 (ex: 254) : " ROUTER2_X
            ROUTER2_IP="$BASE_IP2.$ROUTER2_X"
            read -p "Début de plage DHCP LAN2 (ex: 50) : " RANGE2_START_X
            RANGE2_START="$BASE_IP2.$RANGE2_START_X"
            read -p "Fin de plage DHCP LAN2 (ex: 150) : " RANGE2_END_X
            RANGE2_END="$BASE_IP2.$RANGE2_END_X"

            cat >> /etc/dhcp/dhcpd.conf <<EOL

subnet $BASE_IP2.0 netmask 255.255.255.0 {
    range $RANGE2_START $RANGE2_END;
    option routers $ROUTER2_IP;
    option domain-name-servers $DNS_IP;
    option domain-name "$DOMAIN";
}
EOL
        fi
    fi

    systemctl enable isc-dhcp-server
    systemctl restart isc-dhcp-server
    echo "[OK] Serveur DHCP configuré et démarré."
    systemctl status isc-dhcp-server | head -n 10
}

installer_client() {
    echo "[INFO] Installation du client DHCP..."
    apt update && apt install -y isc-dhcp-client
    read -p "Nom interface client (ex: eth0) : " CLIENT_IF
    dhclient -v $CLIENT_IF
}

tester_dhcp() {
    echo "[INFO] Test DHCP..."
    read -p "Interface à tester (ex: eth0) : " TEST_IF
    ip addr show $TEST_IF
    dhclient -v $TEST_IF
    ip addr show $TEST_IF
    echo "[INFO] Derniers baux DHCP :"
    tail -n 10 /var/lib/dhcp/dhclient.leases
}

desinstaller_dhcp() {
    echo "[INFO] Suppression DHCP serveur + client..."
    apt remove -y isc-dhcp-server isc-dhcp-client
    apt autoremove -y
}

# ==============================
# Menu principal
# ==============================

while true; do
    echo "=============================="
    echo "    SCRIPT DHCP INTERACTIF"
    echo "=============================="
    echo "1) Installer serveur DHCP"
    echo "2) Installer client DHCP"
    echo "3) Tester DHCP"
    echo "4) Désinstaller DHCP"
    echo "0) Quitter"
    echo "=============================="
    read -p "Choix : " CHOIX

    case $CHOIX in
        1) installer_serveur ;;
        2) installer_client ;;
        3) tester_dhcp ;;
        4) desinstaller_dhcp ;;
        0) exit 0 ;;
        *) echo "[ERREUR] Choix invalide !" ;;
    esac
done
