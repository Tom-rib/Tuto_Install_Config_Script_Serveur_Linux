# Installation et configuration de NFS sur Debian 12

## 📋 Table des matières

- [Introduction](#introduction)
- [Installation du serveur NFS](#installation-du-serveur-nfs)
- [Configuration manuelle du client NFS](#configuration-manuelle-du-client-nfs)
- [Tests et vérifications](#tests-et-vérifications)
- [Sécurisation et optimisation](#sécurisation-et-optimisation)
- [Dépannage](#dépannage)
- [Désinstallation propre](#désinstallation-propre)
- [Cas d'usage avancés](#cas-dusage-avancés)

---

## 📖 Introduction

**NFS (Network File System)** est un protocole qui permet de partager des répertoires entre plusieurs machines sous Linux. Il est particulièrement adapté pour :

- 🏠 **Partage de répertoires /home** centralisés
- 📁 **Serveur de fichiers** d'équipe  
- 💾 **Stockage partagé** pour applications
- 🔄 **Synchronisation** de données entre serveurs

### Avantages et limitations

| Avantages | Limitations |
|-----------|-------------|
| ✅ Performance élevée en réseau local | ❌ Sécurité limitée (réseau privé recommandé) |
| ✅ Transparence pour les applications | ❌ Dépendant de la stabilité réseau |
| ✅ Gestion centralisée des permissions | ❌ Pas de chiffrement natif |
| ✅ Support natif Linux | ❌ Configuration parfois complexe |

---

## 🖥️ Installation du serveur NFS

### 1. Mise à jour et installation

```bash
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer le serveur NFS
sudo apt install -y nfs-kernel-server
```

**Paquets installés :**
- `nfs-kernel-server` : Serveur NFS principal
- `nfs-common` : Utilitaires communs (installé automatiquement)
- `rpcbind` : Service RPC (dépendance)

### 2. Création du répertoire partagé

```bash
# Créer la structure de répertoires
sudo mkdir -p /srv/nfs/partage

# Configurer les permissions
sudo chown nobody:nogroup /srv/nfs/partage
sudo chmod 755 /srv/nfs/partage  # Plus sécurisé que 777
```

> **💡 Amélioration sécurité :** Utiliser `755` au lieu de `777` pour éviter l'écriture par tous les utilisateurs.

### 3. Configuration des exports

Éditer le fichier `/etc/exports` :

```bash
sudo nano /etc/exports
```

**Configuration de base :**
```bash
/srv/nfs/partage 192.168.15.0/24(rw,sync,no_subtree_check)
```

**Configuration sécurisée recommandée :**
```bash
/srv/nfs/partage 192.168.15.0/24(rw,sync,no_subtree_check,root_squash,all_squash,anonuid=65534,anongid=65534)
```

#### Options importantes

| Option | Description | Recommandation |
|--------|-------------|----------------|
| `rw` | Lecture/écriture | ✅ Standard |
| `ro` | Lecture seule | ✅ Pour données publiques |
| `sync` | Synchronisation immédiate | ✅ Recommandé (sécurité) |
| `async` | Asynchrone | ⚠️ Plus rapide mais risqué |
| `root_squash` | Root distant → nobody | ✅ **Essentiel pour sécurité** |
| `no_root_squash` | Root distant = root local | ❌ Dangereux |
| `all_squash` | Tous les utilisateurs → nobody | ✅ Pour partage public |
| `no_subtree_check` | Pas de vérification sous-arbre | ✅ Améliore performance |

### 4. Application et activation

```bash
# Appliquer la nouvelle configuration
sudo exportfs -ra

# Vérifier les exports
sudo exportfs -v

# Activer et démarrer les services
sudo systemctl enable --now nfs-kernel-server
sudo systemctl enable --now rpcbind

# Vérifier le statut
sudo systemctl status nfs-kernel-server
```

### 5. Configuration du pare-feu

```bash
# Ouvrir les ports NFS avec UFW
sudo ufw allow from 192.168.15.0/24 to any port nfs
sudo ufw allow from 192.168.15.0/24 to any port 111
sudo ufw allow from 192.168.15.0/24 to any port 2049

# Ou pour iptables
sudo iptables -A INPUT -p tcp -s 192.168.15.0/24 --dport 2049 -j ACCEPT
sudo iptables -A INPUT -p tcp -s 192.168.15.0/24 --dport 111 -j ACCEPT
```

---

## 💻 Configuration manuelle du client NFS

### 1. Installation du client

```bash
# Installer les outils client NFS
sudo apt update
sudo apt install -y nfs-common

# Vérifier l'installation
showmount -e 192.168.15.254
```

### 2. Création du point de montage

```bash
# Créer le répertoire de montage
sudo mkdir -p /mnt/nfs/partage

# Optionnel : ajuster les permissions
sudo chown $USER:$USER /mnt/nfs/partage
```

### 3. Montage manuel

```bash
# Montage temporaire
sudo mount -t nfs 192.168.15.254:/srv/nfs/partage /mnt/nfs/partage

# Montage avec options spécifiques
sudo mount -t nfs -o rw,hard,intr,rsize=8192,wsize=8192 \
    192.168.15.254:/srv/nfs/partage /mnt/nfs/partage
```

### 4. Montage permanent (fstab)

```bash
# Sauvegarder fstab
sudo cp /etc/fstab /etc/fstab.backup

# Ajouter la ligne de montage
echo "192.168.15.254:/srv/nfs/partage /mnt/nfs/partage nfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

# Tester le montage via fstab
sudo umount /mnt/nfs/partage
sudo mount -a
```

> **💡 Amélioration :** L'option `_netdev` indique que le montage nécessite le réseau, retardant le montage jusqu'à ce que le réseau soit disponible.

#### Options de montage avancées

```bash
# Configuration optimisée pour performance
192.168.15.254:/srv/nfs/partage /mnt/nfs/partage nfs rw,hard,intr,rsize=32768,wsize=32768,timeo=14,_netdev 0 0

# Configuration pour connexion instable
192.168.15.254:/srv/nfs/partage /mnt/nfs/partage nfs rw,soft,intr,timeo=30,retrans=3,_netdev 0 0
```

---

## 🧪 Tests et vérifications

### Tests côté serveur

```bash
# Vérifier les exports actifs
showmount -e
sudo exportfs -v

# Vérifier les services
sudo systemctl status nfs-kernel-server
sudo systemctl status rpcbind

# Vérifier les ports ouverts
sudo ss -tulpn | grep -E "(nfs|rpc|mount)"

# Voir les clients connectés
sudo showmount -a
```

### Tests côté client

```bash
# Vérifier la connectivité serveur
ping -c 3 192.168.15.254
telnet 192.168.15.254 2049

# Vérifier les exports disponibles
showmount -e 192.168.15.254

# Vérifier le montage
df -h | grep nfs
mount | grep nfs

# Test d'écriture/lecture
echo "Test NFS $(date)" | sudo tee /mnt/nfs/partage/test.txt
cat /mnt/nfs/partage/test.txt
```

### Test de performance

```bash
# Test d'écriture
time dd if=/dev/zero of=/mnt/nfs/partage/testfile bs=1M count=100 conv=sync

# Test de lecture  
time dd if=/mnt/nfs/partage/testfile of=/dev/null bs=1M

# Nettoyage
rm /mnt/nfs/partage/testfile
```

---

## 🔒 Sécurisation et optimisation

### Configuration sécurisée du serveur

```bash
# /etc/exports sécurisé
/srv/nfs/public     192.168.15.0/24(ro,sync,no_subtree_check,root_squash)
/srv/nfs/users      192.168.15.0/24(rw,sync,no_subtree_check,root_squash,all_squash)
/srv/nfs/admin      192.168.15.10/32(rw,sync,no_subtree_check,no_root_squash)
```

### Optimisation des performances

```bash
# /etc/default/nfs-kernel-server
RPCNFSDCOUNT=8          # Nombre de processus NFS
RPCMOUNTDOPTS="--manage-gids --num-threads=8"

# Redémarrer après modification
sudo systemctl restart nfs-kernel-server
```

### Surveillance et logs

```bash
# Consulter les logs
sudo journalctl -u nfs-kernel-server -f

# Statistiques NFS
nfsstat -s  # Serveur
nfsstat -c  # Client

# Monitoring des connexions
watch 'showmount -a'
```

---

## 🔧 Dépannage

### Problèmes courants

| Problème | Symptôme | Solution |
|----------|----------|----------|
| **Permission denied** | Erreur d'accès | Vérifier `root_squash`, permissions répertoire |
| **Connection refused** | Impossible de monter | Vérifier services, firewall |
| **Stale file handle** | Fichiers inaccessibles | Démonter et remonter |
| **Mount hangs** | Montage bloque | Utiliser option `soft` ou vérifier réseau |

### Commandes de diagnostic

```bash
# Vérifier la configuration
sudo exportfs -v
sudo showmount -e localhost

# Tester RPC
rpcinfo -p localhost
rpcinfo -p 192.168.15.254

# Vérifier les processus
ps aux | grep nfs
sudo lsof -i :2049

# Logs détaillés
sudo tail -f /var/log/syslog | grep nfs
```

### Résolution des problèmes de montage

```bash
# Forcer le démontage
sudo umount -f /mnt/nfs/partage
sudo umount -l /mnt/nfs/partage  # Lazy unmount

# Nettoyer les montages zombies
sudo fuser -km /mnt/nfs/partage

# Redémarrer les services
sudo systemctl restart nfs-kernel-server
sudo systemctl restart rpcbind
```

---

## 🗑️ Désinstallation propre

### Côté client

```bash
# Démonter tous les partages NFS
sudo umount -a -t nfs

# Supprimer les entrées fstab
sudo nano /etc/fstab  # Supprimer les lignes NFS

# Désinstaller le paquet
sudo apt remove --purge -y nfs-common
sudo apt autoremove -y
```

### Côté serveur

```bash
# Arrêter les services
sudo systemctl stop nfs-kernel-server
sudo systemctl disable nfs-kernel-server

# Désinstaller les paquets
sudo apt remove --purge -y nfs-kernel-server
sudo apt autoremove -y

# Nettoyer les répertoires
sudo rm -rf /srv/nfs/
sudo rm -f /etc/exports

# Nettoyer les configurations
sudo rm -rf /var/lib/nfs/
```

---

## 🚀 Cas d'usage avancés

### Partage de répertoires /home

```bash
# Configuration serveur
sudo mkdir -p /srv/nfs/home
sudo cp -a /home/* /srv/nfs/home/
echo "/srv/nfs/home 192.168.15.0/24(rw,sync,no_subtree_check)" >> /etc/exports

# Configuration client
echo "192.168.15.254:/srv/nfs/home /home nfs rw,hard,intr,_netdev 0 0" >> /etc/fstab
```

### Serveur de fichiers multi-partages

```bash
# Structure recommandée
/srv/nfs/
├── public/         # Lecture pour tous
├── groups/
│   ├── dev/        # Groupe développeurs
│   ├── admin/      # Groupe administrateurs
│   └── users/      # Utilisateurs standard
└── backup/         # Sauvegardes

# Configuration /etc/exports
/srv/nfs/public    192.168.15.0/24(ro,sync,no_subtree_check,all_squash)
/srv/nfs/groups/dev 192.168.15.0/24(rw,sync,no_subtree_check,root_squash)
/srv/nfs/backup    192.168.15.0/24(rw,sync,no_subtree_check,all_squash,anonuid=backup,anongid=backup)
```

### Haute disponibilité avec failover

```bash
# Script de basculement automatique
#!/bin/bash
PRIMARY_NFS="192.168.15.254"
SECONDARY_NFS="192.168.15.255"
MOUNT_POINT="/mnt/nfs/partage"

if ! ping -c 1 $PRIMARY_NFS >/dev/null 2>&1; then
    sudo umount $MOUNT_POINT
    sudo mount -t nfs $SECONDARY_NFS:/srv/nfs/partage $MOUNT_POINT
fi
```

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Installation serveur](#installation-du-serveur-nfs)
- [→ Configuration client](#configuration-manuelle-du-client-nfs)
- [→ Tests](#tests-et-vérifications)
- [→ Dépannage](#dépannage)