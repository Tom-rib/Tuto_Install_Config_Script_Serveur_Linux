#!/bin/bash
# Script interactif DHCP serveur/client/test/désinstallation
# Ajout WAN/LAN et NAT auto avec DNS Google si WAN

# Fonction installation serveur DHCP
install_server() {
    echo "[INSTALL SERVEUR DHCP]"
    read -p "Interface LAN principale (fixe, ex: ens33) [default: ens33]: " LAN_IF
    LAN_IF=${LAN_IF:-ens33}

    read -p "Sous-réseau LAN (default: 192.168.15.0): " SUBNET
    SUBNET=${SUBNET:-192.168.15.0}

    read -p "Masque (default: 255.255.255.0): " NETMASK
    NETMASK=${NETMASK:-255.255.255.0}

    read -p "Plage début IP (default: 192.168.15.100): " RANGE_START
    RANGE_START=${RANGE_START:-192.168.15.100}

    read -p "Plage fin IP (default: 192.168.15.200): " RANGE_END
    RANGE_END=${RANGE_END:-192.168.15.200}

    read -p "Passerelle LAN (default: 192.168.15.254): " ROUTER
    ROUTER=${ROUTER:-192.168.15.254}

    read -p "DNS LAN (default: 192.168.15.253): " DNS
    DNS=${DNS:-192.168.15.253}

    read -p "Domaine (default: tutoserveurs.local): " DOMAIN
    DOMAIN=${DOMAIN:-tutoserveurs.local}

    # Vérifier si deuxième interface
    read -p "Ajouter une deuxième interface (y/n)? " ADD_IF
    if [[ "$ADD_IF" == "y" ]]; then
        read -p "Nom de l'interface secondaire (ex: ens34): " SEC_IF
        read -p "Type (wan/lan/none) [default: wan]: " SEC_TYPE
        SEC_TYPE=${SEC_TYPE:-wan}

        if [[ "$SEC_TYPE" == "wan" ]]; then
            read -p "Type WAN (dhcp/static) [default: dhcp]: " WAN_TYPE
            WAN_TYPE=${WAN_TYPE:-dhcp}

            if [[ "$WAN_TYPE" == "static" ]]; then
                read -p "Adresse IP WAN: " WAN_IP
                read -p "Masque WAN (default: 255.255.255.0): " WAN_MASK
                WAN_MASK=${WAN_MASK:-255.255.255.0}
                read -p "Passerelle WAN: " WAN_GW
            fi
        elif [[ "$SEC_TYPE" == "lan" ]]; then
            read -p "Sous-réseau LAN secondaire (default: 192.168.20.0): " SEC_SUBNET
            SEC_SUBNET=${SEC_SUBNET:-192.168.20.0}
            read -p "Masque LAN secondaire (default: 255.255.255.0): " SEC_NETMASK
            SEC_NETMASK=${SEC_NETMASK:-255.255.255.0}
            read -p "Passerelle LAN secondaire (default: 192.168.20.1): " SEC_ROUTER
            SEC_ROUTER=${SEC_ROUTER:-192.168.20.1}
        fi
    fi

    echo "[INFO] Mise à jour des paquets..."
    apt update -y

    echo "[INFO] Installation du serveur DHCP..."
    apt install isc-dhcp-server -y

    echo "[INFO] Configuration de l'interface DHCP : $LAN_IF..."
    sed -i "s|^INTERFACESv4=.*|INTERFACESv4=\"$LAN_IF\"|" /etc/default/isc-dhcp-server

    echo "[INFO] Génération de la configuration DHCP..."
    tee /etc/dhcp/dhcpd.conf > /dev/null <<EOL
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

    # Config réseau si deuxième interface
    if [[ "$ADD_IF" == "y" ]]; then
        echo "[INFO] Configuration de $SEC_IF..."
        if [[ "$SEC_TYPE" == "wan" ]]; then
            if [[ "$WAN_TYPE" == "dhcp" ]]; then
                cat >> /etc/network/interfaces <<EON
auto $SEC_IF
iface $SEC_IF inet dhcp
EON
            elif [[ "$WAN_TYPE" == "static" ]]; then
                cat >> /etc/network/interfaces <<EON
auto $SEC_IF
iface $SEC_IF inet static
    address $WAN_IP
    netmask $WAN_MASK
    gateway $WAN_GW
    dns-nameservers 8.8.8.8
EON
            fi

            echo "[INFO] Activation du forwarding IPv4..."
            sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
            sysctl -p

            echo "[INFO] Configuration iptables NAT (LAN=$LAN_IF, WAN=$SEC_IF)..."
            iptables -t nat -A POSTROUTING -o $SEC_IF -j MASQUERADE
            iptables -A FORWARD -i $SEC_IF -o $LAN_IF -m state --state RELATED,ESTABLISHED -j ACCEPT
            iptables -A FORWARD -i $LAN_IF -o $SEC_IF -j ACCEPT

            echo "[INFO] Sauvegarde iptables..."
            apt install iptables-persistent -y
            netfilter-persistent save
        elif [[ "$SEC_TYPE" == "lan" ]]; then
            echo "[INFO] Ajout configuration LAN secondaire..."
            tee -a /etc/dhcp/dhcpd.conf > /dev/null <<EOL

subnet $SEC_SUBNET netmask $SEC_NETMASK {
    range ${SEC_SUBNET%0}100 ${SEC_SUBNET%0}200;
    option routers $SEC_ROUTER;
    option domain-name-servers $DNS;
    option domain-name "$DOMAIN";
}
EOL
        else
            echo "[INFO] Interface secondaire ignorée (none)."
        fi
    fi

    echo "[INFO] Redémarrage du service DHCP..."
    systemctl restart isc-dhcp-server

    echo "[INFO] Statut du serveur DHCP :"
    systemctl status isc-dhcp-server | head -n 15
}

# Client DHCP
install_client() {
    echo "[INSTALL CLIENT DHCP]"
    read -p "Interface réseau (default: eth0): " INTERFACE
    INTERFACE=${INTERFACE:-eth0}
    apt update -y
    apt install isc-dhcp-client -y
    dhclient -v $INTERFACE
    ip addr show $INTERFACE
}

# Test DHCP
test_dhcp() {
    echo "[TEST DHCP]"
    read -p "Interface réseau à tester (default: eth0): " INTERFACE
    INTERFACE=${INTERFACE:-eth0}
    ip addr show $INTERFACE
    dhclient -v $INTERFACE
    ip addr show $INTERFACE
    if [ -f /var/lib/dhcp/dhclient.leases ]; then
        tail -n 15 /var/lib/dhcp/dhclient.leases
    else
        echo "[WARN] Aucun bail trouvé"
    fi
}

# Désinstallation
uninstall() {
    echo "[DÉSINSTALLATION DHCP]"
    read -p "Supprimer le serveur DHCP (y/n)? " REP
    if [[ "$REP" == "y" ]]; then
        apt remove --purge isc-dhcp-server -y
        rm -f /etc/dhcp/dhcpd.conf
    fi
    read -p "Supprimer le client DHCP (y/n)? " REP
    if [[ "$REP" == "y" ]]; then
        apt remove --purge isc-dhcp-client -y
    fi
}

# Menu
echo "=== SCRIPT DHCP INTERACTIF ==="
echo "1) Installer serveur DHCP"
echo "2) Installer client DHCP"
echo "3) Tester DHCP"
echo "4) Désinstaller DHCP"
echo "0) Quitter"
read -p "Choix: " CHOIX

case $CHOIX in
    1) install_server ;;
    2) install_client ;;
    3) test_dhcp ;;
    4) uninstall ;;
    0) echo "Bye!"; exit 0 ;;
    *) echo "Choix invalide" ;;
esac
