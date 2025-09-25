# 📖 README – Script RAID Interactif (mdadm)

## 📋 Table des matières

- [Présentation](#présentation)
- [Installation](#installation)
- [Menu du script](#menu-du-script)
- [Utilisation détaillée](#utilisation-détaillée)
  - [Créer un RAID](#1️⃣-créer-un-raid)
  - [Supprimer un RAID](#2️⃣-supprimer-un-raid)
  - [Vérifier l'état du RAID](#3️⃣-vérifier-létat-du-raid)
- [Tests pratiques](#tests-pratiques)
- [Exemples d'utilisation](#exemples-dutilisation)
- [Dépannage](#dépannage)
- [Notes importantes](#notes-importantes)

---

## 🚀 Présentation

Ce script permet de gérer facilement les **ensembles RAID logiciels** sous Linux avec `mdadm`. Il propose un **menu interactif** pour :

- ✅ **Créer un RAID** (0, 1, 5, 6, 10)
- ❌ **Supprimer un RAID** existant
- 📊 **Vérifier l'état** des ensembles RAID

Le script **automatise** la configuration, le formatage, le montage et l'ajout dans `/etc/fstab` pour un déploiement rapide et sûr.

### ✨ Fonctionnalités automatiques

| Action            | Description                                        |
|-------------------|----------------------------------------------------|
| **Détection**     | Identification automatique des disques disponibles |
| **Configuration** | Création et paramétrage du RAID avec mdadm         |
| **Formatage**     | Format ext4 automatique après création             |
| **Montage**       | Configuration du point de montage                  |
| **Persistance**   | Ajout automatique dans `/etc/fstab`                |
| **Vérification**  | Contrôles d'intégrité et de fonctionnement         |

---

## ⚙️ Installation

### 1. Télécharger ou créer le script

```bash
# Créer le fichier script
nano raid_interactif.sh

# Ou télécharger depuis un repository
wget https://example.com/raid_interactif.sh
```

### 2. Donner les droits d'exécution

```bash
chmod +x raid_interactif.sh
```

### 3. Lancer le script avec privilèges root

```bash
sudo ./raid_interactif.sh
```

> **⚠️ Prérequis :** Le paquet `mdadm` doit être installé (`sudo apt install mdadm`)

---

## 🖥️ Menu du script

Lorsque vous exécutez le script, un menu interactif apparaît :

```
============================================
         🔧 GESTION RAID (mdadm)
============================================

Disques détectés :
- sdb (10GB) - Disponible
- sdc (10GB) - Disponible  
- sdd (10GB) - Disponible
- sde (10GB) - Disponible

RAID existants :
- /dev/md0 (RAID1) - État: Clean

============================================
1) 🆕 Créer un RAID
2) ❌ Supprimer un RAID
3) 📊 Afficher l'état du RAID
4) 🔄 Rafraîchir l'affichage
5) 🚪 Quitter
============================================

Votre choix [1-5] :
```

---

## 🛠 Utilisation détaillée

### 1️⃣ Créer un RAID

#### Étape 1 : Sélection des disques

Le script affiche la liste des disques disponibles :

```bash
# Exemple d'affichage
Disques disponibles détectés :
sdb    10G   # /dev/sdb (10GB)
sdc    10G   # /dev/sdc (10GB)  
sdd    10G   # /dev/sdd (10GB)
sde    10G   # /dev/sde (10GB)

Entrez les disques à utiliser (ex: sdb sdc sdd) :
```

#### Étape 2 : Choix du type de RAID

```bash
Sélectionnez le type de RAID :
1) RAID 0 - Striping (Performance, aucune redondance)
2) RAID 1 - Mirroring (Redondance, tolérance 1 panne)
3) RAID 5 - Striping + Parité (Bon compromis, tolérance 1 panne)
4) RAID 6 - Striping + Double parité (Haute sécurité, tolérance 2 pannes)
5) RAID 10 - Mirroring + Striping (Performance + redondance, min. 4 disques)

Votre choix [1-5] :
```

#### Caractéristiques par type

| Type        | Min disques | Capacité utilisable | Tolérance pannes  |
|-------------|-------------|---------------------|-------------------|
| **RAID 0**  | 2           | 100%                | ❌ Aucune        |
| **RAID 1**  | 2           | 50%                 | ✅ 1 disque      |
| **RAID 5**  | 3           | ~75% (n-1)/n        | ✅ 1 disque      |
| **RAID 6**  | 4           | ~66% (n-2)/n        | ✅ 2 disques     |
| **RAID 10** | 4 (paires)  | 50%                 | ✅ 1 par miroir  |

#### Étape 3 : Configuration automatique

Le script effectue automatiquement :

1. **Création du RAID** avec `mdadm --create`
2. **Attente de synchronisation** initiale
3. **Formatage ext4** du volume RAID
4. **Configuration du point de montage**
5. **Ajout dans `/etc/fstab`** pour persistance

```bash
🔄 Création du RAID en cours...
✅ RAID créé : /dev/md0
🔄 Formatage en ext4...
✅ Système de fichiers créé
📁 Point de montage : /mnt/raid
✅ Entrée fstab ajoutée
🎉 RAID opérationnel !
```

#### Vérification post-création

```bash
cat /proc/mdstat
sudo mdadm --detail /dev/md0
df -h | grep raid
```

### 2️⃣ Supprimer un RAID

Le script effectue une **suppression propre** :

#### Étapes automatiques

1. **Démontage** du système de fichiers
2. **Suppression** de l'entrée `/etc/fstab`
3. **Arrêt** de l'array RAID
4. **Suppression** de la configuration mdadm
5. **Nettoyage** des superblocks sur les disques

```bash
Sélectionnez le RAID à supprimer :
1) /dev/md0 (RAID1, 2 disques)
2) /dev/md1 (RAID5, 3 disques)

Votre choix : 1

⚠️  ATTENTION : Cette opération va :
   - Démonter /mnt/raid
   - Supprimer le RAID /dev/md0  
   - Effacer les données !

Confirmer la suppression ? [o/N] : o

🔄 Suppression en cours...
✅ Système de fichiers démonté
✅ Entrée fstab supprimée
✅ RAID arrêté et supprimé
✅ Superblocks effacés
🎉 Suppression terminée !
```

#### Équivalent manuel

```bash
# Suppression manuelle (pour référence)
sudo umount /mnt/raid
sudo mdadm --stop /dev/md0
sudo mdadm --remove /dev/md0
sudo mdadm --zero-superblock /dev/sdb /dev/sdc
# Éditer manuellement /etc/fstab
```

### 3️⃣ Vérifier l'état du RAID

Le script affiche un **tableau de bord complet** :

```bash
============================================
         📊 ÉTAT DES RAID ACTIFS
============================================

📈 Statut général (/proc/mdstat) :
md0 : active raid1 sdc[1] sdb[0]
      10475520 blocks super 1.2 [2/2] [UU]
      
md1 : active raid5 sdf[2] sde[1] sdd[0]  
      20951040 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/3] [UUU]

============================================

📋 Détails par RAID :

🔧 /dev/md0 (RAID1) :
   - État : Propre, synchronisé
   - Disques : sdb[0], sdc[1] 
   - Capacité : 10GB
   - Point de montage : /mnt/raid1

🔧 /dev/md1 (RAID5) :
   - État : Propre, synchronisé  
   - Disques : sdd[0], sde[1], sdf[2]
   - Capacité : 20GB
   - Point de montage : /mnt/raid5

============================================
```

---

## 🧪 Tests pratiques

### Après création d'un RAID

```bash
# Vérifier la structure des disques
lsblk

# Vérifier l'espace disponible
df -h

# Vérifier l'état RAID
cat /proc/mdstat

# Tester l'écriture/lecture
sudo dd if=/dev/zero of=/mnt/raid/test.bin bs=1M count=100
sudo rm /mnt/raid/test.bin
```

### Test de performance

```bash
# Benchmark écriture
sudo hdparm -tT /dev/md0

# Test avec dd (écriture)
sudo dd if=/dev/zero of=/mnt/raid/perftest bs=1M count=1000 conv=sync
# Test avec dd (lecture)  
sudo dd if=/mnt/raid/perftest of=/dev/null bs=1M

# Nettoyage
sudo rm /mnt/raid/perftest
```

### Test de redondance (RAID 1/5/6)

```bash
# Simuler une panne
sudo mdadm --manage /dev/md0 --set-faulty /dev/sdb

# Vérifier que le RAID fonctionne encore
cat /proc/mdstat
df -h /mnt/raid

# Retirer le disque défaillant
sudo mdadm --manage /dev/md0 --remove /dev/sdb

# Ajouter un nouveau disque
sudo mdadm --manage /dev/md0 --add /dev/sdX
```

---

## 💡 Exemples d'utilisation

### Serveur web avec RAID 1

```bash
# Création via script
sudo ./raid_interactif.sh
# Choisir : 1 (Créer RAID)
# Disques : sdb sdc  
# Type : 2 (RAID 1)
# Point de montage : /var/www

# Utilisation
sudo chown -R www-data:www-data /var/www
# Configurer Apache/Nginx pour utiliser /var/www
```

### Serveur de fichiers avec RAID 5

```bash
# Création via script
sudo ./raid_interactif.sh
# Choisir : 1 (Créer RAID)
# Disques : sdb sdc sdd
# Type : 3 (RAID 5)  
# Point de montage : /srv/data

# Configuration Samba
sudo nano /etc/samba/smb.conf
# Ajouter partage pointant vers /srv/data
```

### Base de données avec RAID 10

```bash
# Création via script (4 disques minimum)
sudo ./raid_interactif.sh
# Choisir : 1 (Créer RAID)
# Disques : sdb sdc sdd sde
# Type : 5 (RAID 10)
# Point de montage : /var/lib/mysql

# Migration MySQL
sudo systemctl stop mysql
sudo cp -a /var/lib/mysql/* /var/lib/mysql-backup/
sudo mount /dev/md0 /var/lib/mysql
sudo systemctl start mysql
```

---

## 🔧 Dépannage

### Problèmes courants

| Problème                             | Cause                    | Solution                                |
|--------------------------------------|--------------------------|-----------------------------------------|
| **Script ne trouve pas les disques** | Disques déjà montés      | `sudo umount /dev/sdX`                  |
| **Erreur de création RAID**          | Superblocks existants    | `sudo mdadm --zero-superblock /dev/sdX` |
| **RAID ne démarre pas au boot**      | Problème /etc/fstab      | Vérifier la ligne dans fstab            |
| **Performance dégradée**             | Synchronisation en cours | Attendre fin avec `/proc/mdstat`        |

### Commandes de diagnostic

```bash
# État détaillé des RAID
sudo mdadm --detail --scan

# Logs système
sudo dmesg | grep -i raid
sudo journalctl -u mdmonitor

# Vérifier les disques
sudo badblocks -sv /dev/sdX
sudo smartctl -a /dev/sdX
```

### Récupération d'urgence

```bash
# Redémarrer un RAID  
sudo mdadm --assemble /dev/md0 /dev/sdb /dev/sdc

# Forcer l'assemblage (attention !)
sudo mdadm --assemble --force /dev/md0 /dev/sdb /dev/sdc
```

---

## ⚠️ Notes importantes

### 🔒 Sécurité et précautions

> **🚨 Avertissements critiques :**

- **Exécution root requise** : Le script doit être lancé avec `sudo`
- **Perte de données garantie** : Les données sur les disques choisis seront **effacées définitivement**
- **Tests obligatoires** : Toujours tester sur des disques vides avant production
- **Sauvegarde préalable** : Sauvegarder les données importantes avant utilisation

### 🎯 Bonnes pratiques

- **Environnement de test** : Utiliser des VM ou disques de test
- **Documentation** : Noter la configuration RAID déployée  
- **Surveillance** : Configurer les alertes mdadm par email
- **Maintenance** : Planifier des vérifications périodiques
- **Sauvegardes** : RAID ≠ sauvegarde, prévoir des sauvegardes externes

### 📊 Recommandations par usage

| Usage                | RAID recommandé | Justification                     |
|----------------------|-----------------|-----------------------------------|
| **Poste de travail** | RAID 1          | Simplicité + sécurité données     |
| **Serveur web**      | RAID 1 ou 10    | Performance lecture + redondance  |
| **Serveur fichiers** | RAID 5 ou 6     | Bon rapport capacité/sécurité     |
| **Base de données**  | RAID 10         | Performance + haute disponibilité |
| **Stockage archive** | RAID 6          | Sécurité maximale                 |

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Installation](#installation)
- [→ Utilisation](#utilisation-détaillée)
- [→ Tests](#tests-pratiques)
- [→ Exemples](#exemples-dutilisation)