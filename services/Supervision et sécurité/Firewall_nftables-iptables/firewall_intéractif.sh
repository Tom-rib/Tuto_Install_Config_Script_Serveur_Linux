#!/bin/bash
# ==================================================
# Script interactif Firewall (iptables / nftables)
# Installation, configuration des règles, tests et désinstallation
# Compatible avec services classiques + ajout custom
# ==================================================

if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Ce script doit être lancé avec sudo !"
    exit 1
fi

# ---------------------------
# Fonctions
# ---------------------------

installer_firewall() {
    echo "[INFO] Installation de iptables et nftables..."
    apt update && apt install -y iptables nftables netfilter-persistent iptables-persistent

    echo "[CONFIG] Voulez-vous activer le NAT/forwarding ? (y/n)"
    read NAT_CHOICE
    if [ "$NAT_CHOICE" == "y" ]; then
        read -p "Nom de l'interface WAN : " WAN_IF
        read -p "Nom de l'interface LAN : " LAN_IF
        echo "[INFO] Activation du forwarding..."
        sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
        sysctl -p
        iptables -t nat -A POSTROUTING -o $WAN_IF -j MASQUERADE
        iptables -A FORWARD -i $LAN_IF -o $WAN_IF -j ACCEPT
        iptables -A FORWARD -i $WAN_IF -o $LAN_IF -m state --state ESTABLISHED,RELATED -j ACCEPT
    fi

    echo "[CONFIG] Quels services voulez-vous autoriser ?"
    echo "Sélectionnez avec les numéros séparés par des espaces (ex: 1 2 4 10)"
    echo "1) SSH (22/tcp)"
    echo "2) DNS (53/tcp/udp)"
    echo "3) DHCP (67-68/udp)"
    echo "4) HTTP (80/tcp)"
    echo "5) HTTPS (443/tcp)"
    echo "6) FTP (21/tcp)"
    echo "7) SFTP (via SSH)"
    echo "8) Samba (137-139,445/tcp/udp)"
    echo "9) NFS (2049/tcp/udp)"
    echo "10) MySQL/MariaDB (3306/tcp)"
    echo "11) PostgreSQL (5432/tcp)"
    echo "12) LDAP (389/tcp/udp)"
    echo "13) LDAPS (636/tcp)"
    echo "14) OpenVPN (1194/udp)"
    echo "15) WireGuard (51820/udp)"
    echo "16) Apache/Nginx (déjà 80,443 ouverts)"
    echo "17) VOIP / Asterisk (5060/udp, 10000-20000/udp)"
    echo "18) Mail - SMTP (25/tcp), IMAP (143/tcp), IMAPS (993/tcp), POP3 (110/tcp), POP3S (995/tcp)"
    echo "19) Autre (port personnalisé)"
    read SERVICES

    for service in $SERVICES; do
        case $service in
            1) iptables -A INPUT -p tcp --dport 22 -j ACCEPT ;;
            2) iptables -A INPUT -p udp --dport 53 -j ACCEPT && iptables -A INPUT -p tcp --dport 53 -j ACCEPT ;;
            3) iptables -A INPUT -p udp --dport 67:68 -j ACCEPT ;;
            4) iptables -A INPUT -p tcp --dport 80 -j ACCEPT ;;
            5) iptables -A INPUT -p tcp --dport 443 -j ACCEPT ;;
            6) iptables -A INPUT -p tcp --dport 21 -j ACCEPT ;;
            7) echo "[INFO] SFTP utilise SSH (22/tcp), déjà ouvert si SSH activé." ;;
            8) iptables -A INPUT -p udp --dport 137:139 -j ACCEPT && iptables -A INPUT -p tcp --dport 137:139 -j ACCEPT && iptables -A INPUT -p tcp --dport 445 -j ACCEPT && iptables -A INPUT -p udp --dport 445 -j ACCEPT ;;
            9) iptables -A INPUT -p tcp --dport 2049 -j ACCEPT && iptables -A INPUT -p udp --dport 2049 -j ACCEPT ;;
            10) iptables -A INPUT -p tcp --dport 3306 -j ACCEPT ;;
            11) iptables -A INPUT -p tcp --dport 5432 -j ACCEPT ;;
            12) iptables -A INPUT -p tcp --dport 389 -j ACCEPT && iptables -A INPUT -p udp --dport 389 -j ACCEPT ;;
            13) iptables -A INPUT -p tcp --dport 636 -j ACCEPT ;;
            14) iptables -A INPUT -p udp --dport 1194 -j ACCEPT ;;
            15) iptables -A INPUT -p udp --dport 51820 -j ACCEPT ;;
            16) echo "[INFO] Web déjà couvert par HTTP(80) et HTTPS(443)." ;;
            17) iptables -A INPUT -p udp --dport 5060 -j ACCEPT && iptables -A INPUT -p udp --dport 10000:20000 -j ACCEPT ;;
            18) iptables -A INPUT -p tcp --dport 25 -j ACCEPT && iptables -A INPUT -p tcp --dport 143 -j ACCEPT && iptables -A INPUT -p tcp --dport 993 -j ACCEPT && iptables -A INPUT -p tcp --dport 110 -j ACCEPT && iptables -A INPUT -p tcp --dport 995 -j ACCEPT ;;
            19) read -p "Entrez le port personnalisé : " PORT && iptables -A INPUT -p tcp --dport $PORT -j ACCEPT && iptables -A INPUT -p udp --dport $PORT -j ACCEPT ;;
            *) echo "[WARN] Service $service inconnu" ;;
        esac
    done

    # Politique par défaut restrictive
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT

    netfilter-persistent save
    echo "[OK] Pare-feu configuré et activé."
}

tester_firewall() {
    echo "[INFO] Règles iptables actuelles :"
    iptables -L -n -v
    echo "======================================"
    echo "[INFO] Règles NAT :"
    iptables -t nat -L -n -v
}

desinstaller_firewall() {
    echo "[INFO] Réinitialisation du pare-feu..."
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    netfilter-persistent save
    echo "[OK] Pare-feu réinitialisé (tout ouvert)."
}

# ---------------------------
# Menu principal
# ---------------------------

while true; do
    echo "=============================="
    echo "    SCRIPT FIREWALL INTERACTIF"
    echo "=============================="
    echo "1) Installer/Configurer le pare-feu"
    echo "2) Tester les règles"
    echo "3) Réinitialiser/Désinstaller"
    echo "0) Quitter"
    echo "=============================="
    read -p "Choix : " CHOIX

    case $CHOIX in
        1) installer_firewall ;;
        2) tester_firewall ;;
        3) desinstaller_firewall ;;
        0) exit 0 ;;
        *) echo "[ERREUR] Choix invalide !" ;;
    esac
done
