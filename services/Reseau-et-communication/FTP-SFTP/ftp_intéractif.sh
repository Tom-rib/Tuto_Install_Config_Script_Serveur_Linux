#!/bin/bash
# ==================================================
# Script FTP/SFTP interactif
# Installation serveur/client + tests séparés
# ==================================================

set -e

# ---------------------------
# Variables par défaut
# ---------------------------
DEFAULT_FTP_USER=ftpuser
DEFAULT_FTP_PASS=TutoPass123!
DEFAULT_FTP_DIR=
DEFAULT_SERVER_IP=192.168.136.10
DEFAULT_REMOTE_USER=ftpuser

# ---------------------------
# Fonctions
# ---------------------------
install_server() {
    read -p "Nom de l'utilisateur FTP à créer [${DEFAULT_FTP_USER}] : " FTP_USER
    FTP_USER=${FTP_USER:-$DEFAULT_FTP_USER}

    read -sp "Mot de passe pour $FTP_USER [${DEFAULT_FTP_PASS}] : " FTP_PASS_INPUT
    echo
    FTP_PASS=${FTP_PASS_INPUT:-$DEFAULT_FTP_PASS}

    read -p "Répertoire FTP [par défaut /home/$FTP_USER/ftp] : " FTP_DIR_INPUT
    FTP_DIR=${FTP_DIR_INPUT:-/home/$FTP_USER/ftp}

    echo "[INFO] Installation serveur FTP (vsftpd)..."
    sudo apt update
    sudo apt install -y vsftpd

    echo "[INFO] Configuration serveur FTP..."
    sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
    sudo sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
    sudo sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd.conf

    sudo systemctl restart vsftpd
    sudo systemctl enable vsftpd

    # Création utilisateur FTP
    if ! id -u "$FTP_USER" >/dev/null 2>&1; then
        sudo useradd -m "$FTP_USER" -s /bin/bash
        echo "$FTP_USER:$FTP_PASS" | sudo chpasswd
    fi

    # Création répertoire FTP et permissions
    sudo mkdir -p "$FTP_DIR"
    sudo chown -R "$FTP_USER:$FTP_USER" "$FTP_DIR"
    sudo chmod 755 "$FTP_DIR"

    echo "[INFO] Serveur FTP installé et configuré pour l'utilisateur $FTP_USER."
}

install_client() {
    echo "[INFO] Installation client FTP/SFTP..."
    sudo apt update
    sudo apt install -y ftp openssh-client
    echo "[INFO] Client FTP/SFTP installé."
}

test_ftp() {
    read -p "Entrez l'IP du serveur FTP à tester [${DEFAULT_SERVER_IP}] : " SERVER_IP
    SERVER_IP=${SERVER_IP:-$DEFAULT_SERVER_IP}
    read -p "Utilisateur distant pour FTP [${DEFAULT_REMOTE_USER}] : " REMOTE_USER
    REMOTE_USER=${REMOTE_USER:-$DEFAULT_REMOTE_USER}
    read -sp "Mot de passe pour $REMOTE_USER : " REMOTE_PASS
    echo

    echo "[TEST] Connexion FTP au serveur $SERVER_IP avec l'utilisateur $REMOTE_USER..."
    ftp -inv $SERVER_IP <<EOF
user $REMOTE_USER $REMOTE_PASS
ls
bye
EOF
}

test_sftp() {
    read -p "Entrez l'IP du serveur SFTP à tester [${DEFAULT_SERVER_IP}] : " SERVER_IP
    SERVER_IP=${SERVER_IP:-$DEFAULT_SERVER_IP}
    read -p "Utilisateur distant pour SFTP [${DEFAULT_REMOTE_USER}] : " REMOTE_USER
    REMOTE_USER=${REMOTE_USER:-$DEFAULT_REMOTE_USER}

    echo "[TEST] Connexion SFTP au serveur $SERVER_IP avec l'utilisateur $REMOTE_USER..."
    sftp $REMOTE_USER@$SERVER_IP <<EOF
ls
bye
EOF
}

# ---------------------------
# Menu interactif
# ---------------------------
echo "===== Script FTP/SFTP interactif ====="
echo "1) Installer serveur FTP/SFTP"
echo "2) Installer client FTP/SFTP"
echo "3) Installer serveur + client"
echo "4) Tester FTP"
echo "5) Tester SFTP"
read -p "Choix : " CHOICE

case "$CHOICE" in
    1)
        install_server
        ;;
    2)
        install_client
        ;;
    3)
        install_server
        install_client
        ;;
    4)
        test_ftp
        ;;
    5)
        test_sftp
        ;;
    *)
        echo "[ERROR] Choix invalide."
        exit 1
        ;;
esac

echo "[INFO] Script terminé."
