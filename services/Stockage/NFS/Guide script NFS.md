# 📘 README-Script NFS Manager

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Variables configurables](#variables-configurables)
- [Installation et utilisation](#installation-et-utilisation)
- [Menu du script](#menu-du-script)
- [Fonctionnalités détaillées](#fonctionnalités-détaillées)
  - [Installer le serveur NFS](#1️⃣-installer-le-serveur-nfs)
  - [Installer le client NFS](#2️⃣-installer-le-client-nfs)
  - [Tester le serveur](#3️⃣-tester-le-serveur)
  - [Tester le client](#4️⃣-tester-le-client)
  - [Désinstaller NFS](#5️⃣-désinstaller-nfs)
- [Exemples d'utilisation](#exemples-dutilisation)
- [Dépannage et diagnostic](#dépannage-et-diagnostic)
- [Configuration avancée](#configuration-avancée)
- [Sécurité et bonnes pratiques](#sécurité-et-bonnes-pratiques)

---

## 🎯 Vue d'ensemble

Ce script interactif `nfs_manager.sh` permet d'installer, configurer, tester et désinstaller un service **NFS** (Network File System) sur Debian 12. Il centralise toutes les opérations dans un **menu simple** et **automatise** les tâches répétitives.

### ✨ Fonctionnalités principales

- 🔧 **Installation automatique** serveur et client NFS
- ⚙️ **Configuration simplifiée** avec variables personnalisables
- 🧪 **Tests intégrés** pour valider le fonctionnement
- 🗑️ **Désinstallation propre** de tous les composants
- 📊 **Diagnostics** et vérifications automatiques

---

## ⚙️ Variables configurables

En haut du script, vous trouverez des variables modifiables selon votre environnement :

```bash
# === CONFIGURATION NFS ===
IP_SERVEUR="192.168.15.254"        # Adresse IP du serveur NFS
EXPORT_DIR="/srv/nfs/partage"       # Dossier partagé côté serveur  
MOUNT_DIR="/mnt/nfs/partage"        # Point de montage côté client
SUBNET="192.168.15.0/24"            # Réseau autorisé à accéder au partage
NFS_OPTIONS="rw,sync,no_subtree_check"  # Options d'export NFS
MOUNT_OPTIONS="rw,hard,intr"        # Options de montage client
```

### 📋 Description des variables

| Variable | Description | Exemple |
|----------|-------------|---------|
| **IP_SERVEUR** | Adresse IP du serveur NFS | `192.168.15.254` |
| **EXPORT_DIR** | Répertoire partagé sur le serveur | `/srv/nfs/partage` |
| **MOUNT_DIR** | Point de montage sur le client | `/mnt/nfs/partage` |
| **SUBNET** | Réseau autorisé (notation CIDR) | `192.168.15.0/24` |
| **NFS_OPTIONS** | Options d'export du serveur | `rw,sync,no_subtree_check` |
| **MOUNT_OPTIONS** | Options de montage client | `rw,hard,intr` |

### 🔧 Personnalisation

```bash
# Exemple pour un autre réseau
IP_SERVEUR="10.0.1.100"
SUBNET="10.0.1.0/24"
EXPORT_DIR="/data/shared"
MOUNT_DIR="/shared"
```

---

## 🚀 Installation et utilisation

### Prérequis

- Debian 12 ou Ubuntu équivalent
- Accès `sudo`
- Réseau configuré entre serveur et clients

### Installation

```bash
# 1. Télécharger ou créer le script
wget https://example.com/nfs_manager.sh
# ou
nano nfs_manager.sh

# 2. Rendre exécutable
chmod +x nfs_manager.sh

# 3. Lancer avec privilèges
sudo ./nfs_manager.sh
```

---

## 🖥️ Menu du script

Le script propose un **menu interactif** avec 5 options principales :

```
============================================
      🗂️  GESTIONNAIRE NFS v2.0
============================================

Configuration actuelle :
 📡 Serveur NFS  : 192.168.15.254
 📁 Partage      : /srv/nfs/partage  
 🔗 Point montage: /mnt/nfs/partage
 🌐 Réseau       : 192.168.15.0/24

============================================
1) 🖥️  Installer le serveur NFS
2) 💻 Installer le client NFS  
3) 🧪 Tester le serveur
4) 🔍 Tester le client
5) 🗑️  Désinstaller NFS
6) ⚙️  Modifier la configuration
7) 📊 Afficher les statistiques
8) 🚪 Quitter
============================================

Votre choix [1-8] :
```

---

## 🛠️ Fonctionnalités détaillées

### 1️⃣ Installer le serveur NFS

Cette option configure complètement le serveur NFS :

#### Actions automatiques

```bash
🔄 Installation du serveur NFS...
✅ Paquets nfs-kernel-server installés
✅ Répertoire /srv/nfs/partage créé
✅ Permissions configurées (755)
✅ Export /etc/exports configuré
✅ Service NFS redémarré
✅ Ports ouverts dans le pare-feu
🎉 Serveur NFS opérationnel !
```

#### Configuration générée

Le script crée automatiquement :

```bash
# /etc/exports
/srv/nfs/partage 192.168.15.0/24(rw,sync,no_subtree_check,no_root_squash)

# Structure des répertoires
/srv/nfs/
└── partage/
    ├── docs/          # Exemple de sous-dossier
    ├── images/        # Exemple de sous-dossier  
    └── README.txt     # Fichier de test
```

### 2️⃣ Installer le client NFS

Configuration du client pour accéder au partage :

#### Actions automatiques

```bash
🔄 Installation du client NFS...
✅ Paquet nfs-common installé
✅ Point de montage /mnt/nfs/partage créé
✅ Test de connectivité serveur : OK
✅ Montage temporaire réussi
✅ Entrée /etc/fstab ajoutée (optionnel)
🎉 Client NFS configuré !
```

#### Options de montage

```bash
# Montage temporaire
sudo mount -t nfs 192.168.15.254:/srv/nfs/partage /mnt/nfs/partage

# Montage permanent (/etc/fstab)
192.168.15.254:/srv/nfs/partage /mnt/nfs/partage nfs rw,hard,intr 0 0
```

### 3️⃣ Tester le serveur

Vérifications complètes du serveur NFS :

```bash
============================================
       🧪 TEST DU SERVEUR NFS
============================================

📊 État du service :
✅ nfs-kernel-server : actif
✅ rpcbind : actif  
✅ nfs-mountd : actif

📂 Exports configurés :
/srv/nfs/partage    192.168.15.0/24(rw,sync,no_subtree_check)

🔌 Ports réseau :
✅ Port 2049 (NFS) : ouvert
✅ Port 111 (RPC) : ouvert
✅ Port 20048 (mountd) : ouvert

📁 Répertoire partagé :
✅ /srv/nfs/partage existe
✅ Permissions : 755 (nfsnobody:nogroup)
✅ Espace libre : 15.2GB

🌐 Tests de connectivité :
✅ showmount -e localhost : OK
✅ rpcinfo -p localhost : OK

============================================
🎉 Serveur NFS : OPÉRATIONNEL
============================================
```

### 4️⃣ Tester le client

Tests complets côté client :

```bash
============================================
       🔍 TEST DU CLIENT NFS
============================================

🔗 Test de connectivité :
✅ Ping serveur 192.168.15.254 : OK
✅ Port NFS 2049 accessible : OK
✅ showmount -e 192.168.15.254 : OK

📁 Test de montage :
✅ Point de montage /mnt/nfs/partage créé
✅ Montage NFS : réussi
✅ Répertoire accessible : OK

📝 Test d'écriture/lecture :
✅ Création fichier test : OK
✅ Écriture données : OK  
✅ Lecture données : OK
✅ Suppression fichier : OK

⚡ Test de performance :
📈 Débit écriture : 45.2 MB/s
📈 Débit lecture  : 52.1 MB/s
📈 Latence       : 2.3 ms

============================================
🎉 Client NFS : FONCTIONNEL
============================================
```

### 5️⃣ Désinstaller NFS

Suppression propre de tous les composants :

```bash
⚠️  DÉSINSTALLATION NFS

Que souhaitez-vous désinstaller ?
1) Serveur NFS uniquement
2) Client NFS uniquement  
3) Serveur ET client NFS
4) Annuler

Votre choix : 3

🔄 Désinstallation en cours...
✅ Partages démontés
✅ Entrées /etc/fstab supprimées
✅ Services NFS arrêtés
✅ Paquets désinstallés
✅ Répertoires nettoyés
✅ Configuration supprimée
🎉 Désinstallation terminée !
```

---

## 💡 Exemples d'utilisation

### Serveur de fichiers d'équipe

```bash
# Configuration pour partage d'équipe
IP_SERVEUR="192.168.1.100"
EXPORT_DIR="/srv/nfs/equipe"
SUBNET="192.168.1.0/24"

# Lancer le script
sudo ./nfs_manager.sh
# Choisir : 1 (Installer serveur)

# Structure recommandée
sudo mkdir -p /srv/nfs/equipe/{documents,projets,archives}
sudo chown -R nobody:nogroup /srv/nfs/equipe
```

### Sauvegarde centralisée

```bash
# Configuration pour serveur de sauvegarde
EXPORT_DIR="/srv/nfs/backup"
NFS_OPTIONS="rw,sync,no_subtree_check,root_squash"

# Clients se connectent pour déposer leurs sauvegardes
# sur /mnt/nfs/backup
```

### Développement collaboratif

```bash
# Partage de code source
EXPORT_DIR="/srv/nfs/dev"
SUBNET="10.0.0.0/8"
MOUNT_OPTIONS="rw,soft,intr"  # Plus tolérant aux déconnexions

# Structure type
/srv/nfs/dev/
├── projets/
├── libraries/
└── tools/
```

---

## 🔧 Dépannage et diagnostic

### Conseils de débogage intégrés

Le script inclut des commandes de diagnostic automatiques :

#### Vérifier les ports NFS

```bash
# Commande intégrée au script
sudo ss -tulpn | grep -E "(nfs|rpc|mount)"

# Résultat attendu
tcp   LISTEN 0   64   0.0.0.0:2049   0.0.0.0:*    # NFS
tcp   LISTEN 0   128  0.0.0.0:111    0.0.0.0:*    # RPC
udp   UNCONN 0   0    0.0.0.0:111    0.0.0.0:*    # RPC
```

#### Vérifier les exports côté serveur

```bash
# Commande intégrée au script
showmount -e localhost

# Résultat attendu
Export list for localhost:
/srv/nfs/partage 192.168.15.0/24
```

#### Vérifier les logs système

```bash
# Commande intégrée au script
sudo journalctl -xe | grep -i nfs | tail -10

# Exemples de logs utiles
nfs: server 192.168.15.254 OK
nfs: mount version 1.3.0
```

### Problèmes courants et solutions

| Problème | Cause possible | Solution dans le script |
|----------|----------------|------------------------|
| **Permission denied** | Mauvaise config exports | Script vérifie et corrige `/etc/exports` |
| **Connection refused** | Service arrêté | Script redémarre automatiquement les services |
| **Stale file handle** | Montage corrompu | Script démonte et remonte proprement |
| **Firewall bloque** | Ports fermés | Script configure automatiquement UFW |

### Commandes de diagnostic manuel

```bash
# Tests réseau
ping 192.168.15.254
telnet 192.168.15.254 2049

# Tests RPC  
rpcinfo -p 192.168.15.254
showmount -e 192.168.15.254

# Tests système
sudo exportfs -v
sudo systemctl status nfs-kernel-server
```

---

## ⚙️ Configuration avancée

### Options NFS avancées

Le script permet de personnaliser les options NFS :

```bash
# Options serveur courantes
NFS_OPTIONS="rw,sync,no_subtree_check,no_root_squash"
# rw = lecture/écriture
# sync = synchronisation immédiate  
# no_subtree_check = pas de vérification sous-arbre
# no_root_squash = root distant = root local

# Options client courantes  
MOUNT_OPTIONS="rw,hard,intr,rsize=8192,wsize=8192"
# hard = retry en cas d'erreur
# intr = interruptible par signal
# rsize/wsize = taille des blocs I/O
```

### Configuration multi-exports

```bash
# Exemple de /etc/exports généré
/srv/nfs/public    192.168.15.0/24(ro,sync,no_subtree_check)
/srv/nfs/private   192.168.15.10/32(rw,sync,no_subtree_check) 
/srv/nfs/backup    192.168.15.0/24(rw,async,no_subtree_check,root_squash)
```

### Optimisation performances

```bash
# Variables optimisées pour performance
MOUNT_OPTIONS="rw,hard,intr,rsize=32768,wsize=32768,timeo=14,intr"

# Configuration serveur
echo 'RPCNFSDCOUNT=16' >> /etc/default/nfs-kernel-server
echo 'RPCMOUNTDOPTS="--manage-gids --num-threads=16"' >> /etc/default/nfs-kernel-server
```

---

## 🛡️ Sécurité et bonnes pratiques

### 🔒 Sécurisation du script

Le script intègre plusieurs mesures de sécurité :

```bash
# Vérifications automatiques
- Contrôle des permissions sur les répertoires partagés
- Configuration firewall automatique
- Validation des adresses IP et réseaux
- Options sécurisées par défaut (root_squash)
```

### 📋 Recommandations de sécurité

> **🚨 Points critiques à vérifier :**

- **Réseau fermé** : Utiliser NFS uniquement sur réseau privé/VPN
- **Authentification** : Considérer NFSv4 avec Kerberos pour environnements sensibles
- **Chiffrement** : Utiliser un tunnel SSH/VPN pour les connexions WAN
- **Permissions** : Appliquer le principe du moindre privilège
- **Monitoring** : Surveiller les connexions et accès aux partages

### 🎯 Bonnes pratiques d'utilisation

```bash
# Structure recommandée
/srv/nfs/
├── public/     # Lecture seule, tous les clients
├── groups/     # Par groupe d'utilisateurs  
├── users/      # Répertoires individuels
└── backup/     # Sauvegardes (write-only si possible)

# Script de surveillance
#!/bin/bash
# /usr/local/bin/nfs-monitor.sh
showmount -a | mail -s "Connexions NFS" admin@example.com
```

### 📊 Monitoring et alertes

```bash
# Intégration dans le script d'alertes
if ! showmount -e localhost >/dev/null 2>&1; then
    echo "ALERTE: Serveur NFS inaccessible" | mail -s "NFS Alert" admin@example.com
fi

# Statistiques d'utilisation
nfsstat -s  # Côté serveur
nfsstat -c  # Côté client
```

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Variables](#variables-configurables)
- [→ Menu](#menu-du-script)
- [→ Fonctionnalités](#fonctionnalités-détaillées)
- [→ Dépannage](#dépannage-et-diagnostic)