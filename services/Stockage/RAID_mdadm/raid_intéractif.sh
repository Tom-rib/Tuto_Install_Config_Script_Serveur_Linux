#!/bin/bash
# ==================================================
# Script interactif avancé RAID (mdadm)
# Auteur : ChatGPT
# ==================================================
# Permet :
#  - Détection des disques disponibles
#  - Vérification disques vides
#  - Choix du type de RAID (0,1,5,6,10)
#  - Création et formatage du RAID
#  - Montage automatique + ajout dans /etc/fstab
#  - Option de suppression/démontage
# ==================================================

set -e

function list_disks() {
    echo "==== Disques disponibles ===="
    lsblk -d -o NAME,SIZE,TYPE | grep disk
    echo "============================="
}

function create_raid() {
    list_disks
    echo "[INFO] Entrez les disques à utiliser pour le RAID (ex: sdb sdc sdd) :"
    read -p " > " DISKS

    # Vérification disques
    for d in $DISKS; do
        if mount | grep "/dev/$d" >/dev/null; then
            echo "[ERREUR] Le disque /dev/$d est déjà monté. Démontez-le avant."
            exit 1
        fi
        if sudo fdisk -l /dev/$d | grep -q "Linux filesystem"; then
            echo "[WARN] Le disque /dev/$d contient déjà une partition Linux."
            read -p "Voulez-vous l’utiliser quand même ? (y/n) : " CONFIRM
            [[ $CONFIRM != "y" ]] && exit 1
        fi
    done

    echo "Types de RAID disponibles :"
    echo "  0) RAID0 (Performance, sans redondance)"
    echo "  1) RAID1 (Mirroring, redondance totale)"
    echo "  5) RAID5 (Performance + parité, tolère 1 panne)"
    echo "  6) RAID6 (Double parité, tolère 2 pannes)"
    echo " 10) RAID10 (Performance + redondance, minimum 4 disques)"
    read -p "Choisissez le type de RAID : " RAID_TYPE

    read -p "Nom du RAID (ex: md0) : " RAID_NAME
    RAID_DEVICES=$(echo $DISKS | wc -w)

    echo "[INFO] Création du RAID /dev/$RAID_NAME en cours..."
    sudo mdadm --create --verbose /dev/$RAID_NAME --level=$RAID_TYPE --raid-devices=$RAID_DEVICES $DISKS

    echo "[INFO] Sauvegarde de la configuration RAID..."
    sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf

    read -p "Voulez-vous formater le RAID en ext4 ? (y/n) : " FORMAT
    if [[ $FORMAT == "y" ]]; then
        sudo mkfs.ext4 /dev/$RAID_NAME
    fi

    read -p "Point de montage (ex: /mnt/raid) : " MNT_POINT
    sudo mkdir -p $MNT_POINT
    sudo mount /dev/$RAID_NAME $MNT_POINT

    UUID=$(blkid -s UUID -o value /dev/$RAID_NAME)
    echo "UUID=$UUID $MNT_POINT ext4 defaults 0 0" | sudo tee -a /etc/fstab

    echo "[OK] RAID créé et monté sur $MNT_POINT"
    echo "[INFO] Vérifiez l’état avec : cat /proc/mdstat"
}

function remove_raid() {
    read -p "Nom du RAID à démonter (ex: md0) : " RAID_NAME
    read -p "Point de montage (ex: /mnt/raid) : " MNT_POINT

    echo "[INFO] Démontage du RAID..."
    sudo umount $MNT_POINT || true
    sudo sed -i "\|/dev/$RAID_NAME|d" /etc/fstab
    sudo sed -i "\|$MNT_POINT|d" /etc/fstab

    echo "[INFO] Arrêt et suppression du RAID..."
    sudo mdadm --stop /dev/$RAID_NAME || true
    sudo mdadm --remove /dev/$RAID_NAME || true

    echo "[INFO] Nettoyage des disques..."
    for d in $(lsblk -ndo NAME /dev/$RAID_NAME); do
        sudo mdadm --zero-superblock /dev/$d || true
    done

    echo "[OK] RAID supprimé proprement."
}

echo "==== Gestion RAID (mdadm) ===="
echo "1) Créer un RAID"
echo "2) Supprimer un RAID"
echo "3) Afficher l’état du RAID"
read -p "Choix : " CHOICE

case $CHOICE in
    1) create_raid ;;
    2) remove_raid ;;
    3) cat /proc/mdstat && sudo mdadm --detail --scan ;;
    *) echo "[ERREUR] Choix invalide." ;;
esac
