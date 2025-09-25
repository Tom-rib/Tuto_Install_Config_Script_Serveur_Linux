#!/bin/bash

# =====================================
# Script NFS Manager v46 – Debian 12
# =====================================

# Vérification root
if [[ $(id -u) -ne 0 ]]; then
    echo -e "\e[31m[ERREUR]\e[0m Ce script doit être exécuté en root."
    exit 1
fi

# ========================
# Fonctions
# ========================

installer_serveur() {
    read -rp "Nom du dossier à partager côté serveur (ex: partage) : " EXPORT_NAME
    read -rp "IP ou réseau autorisé à accéder au partage (ex: 192.168.136.0/24) : " SUBNET
    read -rp "IP de cette machine (serveur) : " IP_SERVEUR

    EXPORT_DIR="/srv/nfs/$EXPORT_NAME"

    echo -e "\e[34m[INFO]\e[0m Installation du serveur NFS..."
    apt update && apt install -y nfs-kernel-server nfs-common

    # Création du dossier et droits
    mkdir -p "$EXPORT_DIR"
    chown -R nobody:nogroup "$EXPORT_DIR"
    chmod -R 777 "$EXPORT_DIR"

    # Vérification format subnet
    if [[ $SUBNET =~ \.[0-9]+$ ]]; then
        SUBNET="${SUBNET}/24"
    fi

    # Écriture sécurisée dans /etc/exports
    grep -q "$EXPORT_DIR" /etc/exports || echo "$EXPORT_DIR $SUBNET(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports

    # Recharger exports et redémarrer le service
    exportfs -ra
    systemctl enable --now nfs-server
    systemctl restart nfs-server

    echo -e "\e[32m[SERVEUR NFS INSTALLÉ]\e[0m"
    echo -e "\e[36m[INFO]\e[0m Dossier exporté : $EXPORT_DIR"
    echo -e "\e[36m[INFO]\e[0m Les clients peuvent monter ce partage avec :"
    echo -e "    sudo mount $IP_SERVEUR:$EXPORT_DIR /mnt/nfs/<point_de_montage>"
}

installer_client() {
    read -rp "IP du serveur NFS : " IP_SERVEUR
    read -rp "Nom du dossier côté serveur à monter (ex: partage) : " EXPORT_NAME
    read -rp "Nom du point de montage local côté client (ex: mon_partage) : " MOUNT_NAME

    EXPORT_DIR="/srv/nfs/$EXPORT_NAME"
    MOUNT_DIR="/mnt/nfs/$MOUNT_NAME"

    echo -e "\e[34m[INFO]\e[0m Installation du client NFS..."
    apt update && apt install -y nfs-common

    mkdir -p "$MOUNT_DIR"

    # Montage immédiat
    mount | grep -q "$MOUNT_DIR" || mount "$IP_SERVEUR:$EXPORT_DIR" "$MOUNT_DIR"

    # Ajout fstab si nécessaire
    grep -q "$EXPORT_DIR" /etc/fstab || echo "$IP_SERVEUR:$EXPORT_DIR $MOUNT_DIR nfs defaults 0 0" >> /etc/fstab

    echo -e "\e[32m[CLIENT NFS INSTALLÉ]\e[0m"
    echo -e "\e[36m[INFO]\e[0m Dossier monté dans : $MOUNT_DIR"
    echo -e "\e[34m[INFO]\e[0m Contenu du dossier partagé :"
    ls -l "$MOUNT_DIR"
}

installer_tout() {
    echo -e "\e[33m[INFO]\e[0m Installation serveur + client"
    installer_serveur
    installer_client
}

tester_serveur() {
    read -rp "IP du serveur NFS : " IP_SERVEUR
    echo -e "\e[34m[INFO]\e[0m Vérification des exports..."
    showmount -e "$IP_SERVEUR"
}

tester_client() {
    read -rp "IP du serveur NFS : " IP_SERVEUR
    read -rp "Nom du dossier côté serveur (ex: partage) : " EXPORT_NAME
    read -rp "Nom du point de montage local côté client (ex: mon_partage) : " MOUNT_NAME

    EXPORT_DIR="/srv/nfs/$EXPORT_NAME"
    MOUNT_DIR="/mnt/nfs/$MOUNT_NAME"

    echo -e "\e[34m[INFO]\e[0m Test de montage..."
    mount | grep -q "$MOUNT_DIR" || mount "$IP_SERVEUR:$EXPORT_DIR" "$MOUNT_DIR"
    ls -l "$MOUNT_DIR"
    echo -e "\e[32m[CLIENT NFS OK]\e[0m"
    echo -e "\e[36m[INFO]\e[0m Vous pouvez accéder au partage avec : cd $MOUNT_DIR"
}

demonter_partage_client() {
    echo -e "\e[36m[INFO]\e[0m Points de montage disponibles côté client :"
    if [ -d /mnt/nfs ] && [ "$(ls -A /mnt/nfs)" ]; then
        ls -1 /mnt/nfs
    else
        echo "  Aucun point de montage"
    fi

    read -rp "Nom du point de montage local à démonter (ex: mon_partage) : " MOUNT_NAME
    MOUNT_DIR="/mnt/nfs/$MOUNT_NAME"

    if mount | grep -q "$MOUNT_DIR"; then
        umount "$MOUNT_DIR"
        echo -e "\e[32m[OK]\e[0m Partage démonté : $MOUNT_DIR"
    else
        echo -e "\e[33m[INFO]\e[0m Aucun montage actif trouvé sur : $MOUNT_DIR"
    fi
}

desinstaller() {
    echo -e "\e[36m[INFO]\e[0m Dossiers de partage disponibles côté serveur :"
    if [ -d /srv/nfs ] && [ "$(ls -A /srv/nfs)" ]; then
        ls -1 /srv/nfs
    else
        echo "  Aucun partage disponible"
    fi

    read -rp "Nom du dossier serveur à supprimer (ex: partage) : " EXPORT_NAME
    EXPORT_DIR="/srv/nfs/$EXPORT_NAME"

    echo -e "\e[36m[INFO]\e[0m Points de montage disponibles côté client :"
    if [ -d /mnt/nfs ] && [ "$(ls -A /mnt/nfs)" ]; then
        ls -1 /mnt/nfs
    else
        echo "  Aucun point de montage"
    fi

    read -rp "Nom du point de montage local côté client à supprimer (ex: mon_partage) : " MOUNT_NAME
    MOUNT_DIR="/mnt/nfs/$MOUNT_NAME"

    echo -e "\e[34m[INFO]\e[0m Suppression du partage..."

    if mount | grep -q "$MOUNT_DIR"; then
        umount "$MOUNT_DIR"
        echo -e "\e[32m[OK]\e[0m Partage démonté : $MOUNT_DIR"
    fi

    rm -rf "$EXPORT_DIR" "$MOUNT_DIR"
    echo -e "\e[32m[OK]\e[0m Dossiers supprimés : $EXPORT_DIR et $MOUNT_DIR"

    sed -i "\|$EXPORT_DIR|d" /etc/exports
    exportfs -ra
    echo -e "\e[32m[OK]\e[0m Export NFS mis à jour côté serveur"
}

# ========================
# Menu principal
# ========================

while true; do
    # Affichage des dossiers existants
    echo -e "\e[36m[INFO]\e[0m Dossiers de partage disponibles côté serveur :"
    if [ -d /srv/nfs ] && [ "$(ls -A /srv/nfs)" ]; then
        ls -1 /srv/nfs
    else
        echo "  Aucun partage disponible"
    fi

    echo -e "\e[36m[INFO]\e[0m Points de montage disponibles côté client :"
    if [ -d /mnt/nfs ] && [ "$(ls -A /mnt/nfs)" ]; then
        ls -1 /mnt/nfs
    else
        echo "  Aucun point de montage"
    fi

    # Menu interactif
    echo -e "\n\e[33m=== MENU NFS MANAGER ===\e[0m"
    echo "1) Installer le serveur"
    echo "2) Installer le client"
    echo "3) Installer serveur + client"
    echo "4) Tester le serveur"
    echo "5) Tester le client"
    echo "6) Supprimer un partage (serveur + client)"
    echo "7) Démonter un partage côté client"
    echo "0) Quitter"
    read -rp "Choix : " choix

    case $choix in
        1) installer_serveur ;;
        2) installer_client ;;
        3) installer_tout ;;
        4) tester_serveur ;;
        5) tester_client ;;
        6) desinstaller ;;
        7) demonter_partage_client ;;
        0) echo "Bye!"; exit 0 ;;
        *) echo -e "\e[31m[ERREUR]\e[0m Choix invalide." ;;
    esac
done
