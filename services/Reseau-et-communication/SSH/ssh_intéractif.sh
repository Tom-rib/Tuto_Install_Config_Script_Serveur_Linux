#!/bin/bash
# ==================================================
# Script SSH complet sécurisé
# Installation serveur + client + clé SSH
# ==================================================

set -e

# ---------------------------
# Variables par défaut
# ---------------------------
SSH_USER=${SSH_USER:-$USER}               # Utilisateur local pour créer la clé
SSH_PORT=${SSH_PORT:-22}                  # Port SSH
REMOTE_USER=${REMOTE_USER:-$SSH_USER}    # Utilisateur distant
REMOTE_IP=${REMOTE_IP:-192.168.136.10n}   # IP du serveur distant

# ---------------------------
# Fonctions
# ---------------------------
install_server() {
    echo "[INFO] Installation du serveur SSH..."
    sudo apt update
    sudo apt install -y openssh-server
    echo "[INFO] Configuration du serveur SSH..."
    sudo sed -i "s/#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
    sudo sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
    sudo sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" /etc/ssh/sshd_config
    sudo systemctl restart ssh
    echo "[INFO] Serveur SSH installé et configuré sur le port $SSH_PORT."
}

install_client() {
    echo "[INFO] Installation du client SSH..."
    sudo apt update
    sudo apt install -y openssh-client
    echo "[INFO] Client SSH installé."
}

generate_key() {
    read -p "Voulez-vous générer une nouvelle clé SSH ? (y/n) : " GENERATE_KEY
    if [[ "$GENERATE_KEY" =~ ^[Yy]$ ]]; then
        read -p "Nom de la clé (ex: id_rsa_custom) : " KEY_NAME
        KEY_NAME=${KEY_NAME:-id_rsa}
        KEY_PATH="/home/$SSH_USER/.ssh/$KEY_NAME"

        # Générer la clé en tant qu'utilisateur non-root
        sudo -u $SSH_USER ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -C "$SSH_USER@$(hostname)" -N ""

        # Appliquer les droits corrects
        sudo chmod 700 /home/$SSH_USER/.ssh
        sudo chmod 600 "$KEY_PATH"
        sudo chmod 644 "$KEY_PATH.pub"
        sudo chown -R $SSH_USER:$SSH_USER /home/$SSH_USER/.ssh

        echo "[INFO] Clé générée : $KEY_PATH"

        read -p "Voulez-vous copier cette clé vers un serveur distant ? (y/n) : " COPY_KEY
        if [[ "$COPY_KEY" =~ ^[Yy]$ ]]; then
            read -p "Utilisateur distant : " REMOTE_USER_INPUT
            REMOTE_USER=${REMOTE_USER_INPUT:-$REMOTE_USER}
            read -p "IP du serveur distant : " REMOTE_IP_INPUT
            REMOTE_IP=${REMOTE_IP_INPUT:-$REMOTE_IP}

            sudo -u $SSH_USER ssh-copy-id -i "$KEY_PATH.pub" "$REMOTE_USER@$REMOTE_IP"
            echo "[INFO] Clé copiée sur $REMOTE_USER@$REMOTE_IP"

            # Test de connexion avec la clé
            echo "[INFO] Test de connexion avec la clé..."
            sudo -u $SSH_USER ssh -i "$KEY_PATH" -p $SSH_PORT "$REMOTE_USER@$REMOTE_IP" "echo 'Connexion réussie !'"
        fi
    fi
}

# ---------------------------
# Menu interactif
# ---------------------------
echo "===== Script SSH automatique ====="
echo "1) Installer serveur SSH"
echo "2) Installer client SSH"
echo "3) Installer les deux"
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
    *)
        echo "[ERROR] Choix invalide."
        exit 1
        ;;
esac

# ---------------------------
# Génération de clé optionnelle
# ---------------------------
generate_key

echo "[INFO] Script terminé."
