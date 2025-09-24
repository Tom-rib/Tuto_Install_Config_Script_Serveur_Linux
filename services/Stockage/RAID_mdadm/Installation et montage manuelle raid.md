# 1️⃣ README – Installation manuelle RAID avec mdadm

## 📋 Table des matières

- [Prérequis](#prérequis)
- [Installation des outils](#installation-des-outils)
- [Types de RAID](#types-de-raid)
- [Création d'un RAID](#création-dun-raid)
  - [Identification des disques](#identification-des-disques)
  - [Création du RAID](#création-du-raid)
  - [Vérification et sauvegarde](#vérification-et-sauvegarde)
- [Montage et utilisation](#montage-et-utilisation)
- [Tests et vérifications](#tests-et-vérifications)
- [Maintenance et surveillance](#maintenance-et-surveillance)
- [Réinitialisation/Désinstallation](#réinitialisationdésinstallation)
- [Dépannage](#dépannage)
- [Bonnes pratiques](#bonnes-pratiques)

---

## ✅ Prérequis

- Système Linux (Debian/Ubuntu)
- Accès root ou sudo
- **Au moins 2 disques** ou partitions pour RAID 1
- **3 disques ou plus** pour RAID 5/6/10
- Disques de **taille similaire** (recommandé)

> **⚠️ Attention :** La création d'un RAID détruit toutes les données existantes sur les disques utilisés !

---

## 📥 Installation des outils

```bash
sudo apt update
sudo apt install -y mdadm
```

**Outils installés :**
- `mdadm` : Gestionnaire de RAID logiciel Linux
- Scripts de surveillance et maintenance automatiques

---

## ⚙️ Types de RAID

| Type        | Description             | Nb min |                Avantages       Inconvénients                          |
|             |                         | disques|                                                                     
|-------------|-------------------------|--------|-----------------------------------------------------------------------|
| **RAID 0**  | Striping, performance   | 2      | ✅ Performance maximale  ❌ Aucune redondance 
| **RAID 1**  | Mirroring, sécurité     | 2      | ✅ Sécurité des données✅ Performance lecture | ❌ Capacité divisée par 2 |
| **RAID 5**  | Striping + parité       | 3      | ✅ Bon compromis perf/sécurité✅ Tolérance 1 disque| ❌ Performance Write|
| **RAID 6**  | Striping + double parité| 4      | ✅ Tolérance 2 disques✅ Haute sécurité | ❌ Performance write réduite|
| **RAID 10** | Combinaison RAID 1 + 0  | 4paires| ✅ Performance + sécurité | ❌ Coût élevé (50% capacité) |

### Capacité utilisable par type

| Type RAID  | Formule capacité      | Exemple (4×1TB) |
|------------|-----------------------|-----------------|
| **RAID 0** | n × taille_disque     | 4TB             |
| **RAID 1** | taille_disque         | 1TB             |
| **RAID 5** | (n-1) × taille_disque | 3TB             |
| **RAID 6** | (n-2) × taille_disque | 2TB             |
| **RAID 10**| (n/2) × taille_disque| 2TB              |

---

## 💽 Création d'un RAID

### Identification des disques

```bash
# Lister tous les dispositifs de stockage
lsblk

# Afficher les détails des disques
sudo fdisk -l

# Vérifier qu'aucun disque n'est monté
mount | grep -E "(sdb|sdc|sdd)"
```

**Exemple de sortie lsblk :**
```
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   20G  0 disk 
├─sda1   8:1    0   19G  0 part /
└─sda2   8:2    0    1G  0 part [SWAP]
sdb      8:16   0    5G  0 disk 
sdc      8:32   0    5G  0 disk 
sdd      8:48   0    5G  0 disk 
```

### Création du RAID

#### RAID 1 (Mirroring) - 2 disques

```bash
sudo mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc
```

#### RAID 5 (Striping + Parité) - 3 disques

```bash
sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd
```

#### RAID 10 (Mirroring + Striping) - 4 disques

```bash
sudo mdadm --create --verbose /dev/md0 --level=10 --raid-devices=4 /dev/sdb /dev/sdc /dev/sdd /dev/sde
```

### Vérification et sauvegarde

```bash
# Vérifier l'état de construction
cat /proc/mdstat

# Détails complets du RAID
sudo mdadm --detail /dev/md0

# Sauvegarder la configuration
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
```

**Exemple de sortie /proc/mdstat :**
```
md0 : active raid1 sdc[1] sdb[0]
      5238272 blocks super 1.2 [2/2] [UU]
      [>....................]  resync =  1.2% (65536/5238272)
```

---

## 💾 Montage et utilisation

### 1. Créer un système de fichiers

```bash
# Attendre la fin de la synchronisation
sudo mdadm --wait /dev/md0

# Créer le système de fichiers ext4
sudo mkfs.ext4 /dev/md0

# Alternative : système de fichiers XFS (recommandé pour gros volumes)
# sudo mkfs.xfs /dev/md0
```

### 2. Créer le point de montage

```bash
sudo mkdir -p /mnt/raid
sudo chown $USER:$USER /mnt/raid
```

### 3. Montage temporaire

```bash
sudo mount /dev/md0 /mnt/raid
```

### 4. Montage automatique au démarrage

```bash
# Éditer fstab
sudo nano /etc/fstab

# Ajouter la ligne suivante :
/dev/md0   /mnt/raid   ext4   defaults,noatime   0 2
```

**Options recommandées pour fstab :**
- `defaults` : Options par défaut
- `noatime` : Améliore les performances (pas de mise à jour de l'heure d'accès)
- `0` : Pas de sauvegarde avec dump
- `2` : Vérification fsck (1=priorité, 2=standard, 0=jamais)

### 5. Test du montage automatique

```bash
# Démonter
sudo umount /mnt/raid

# Remonter via fstab
sudo mount -a

# Vérifier
df -h /mnt/raid
```

---

## 🧪 Tests et vérifications

### Vérification du montage

```bash
# Afficher les systèmes de fichiers montés
df -h | grep raid

# Afficher les détails du RAID
sudo mdadm --detail /dev/md0

# Vérifier l'état général
cat /proc/mdstat
```

### Test de performance

```bash
# Test d'écriture
sudo dd if=/dev/zero of=/mnt/raid/testfile bs=1M count=1000 conv=sync

# Test de lecture
sudo dd if=/mnt/raid/testfile of=/dev/null bs=1M

# Nettoyer
sudo rm /mnt/raid/testfile
```

### Test de redondance (RAID 1/5/6 uniquement)

```bash
# Simuler une panne de disque
sudo mdadm --manage /dev/md0 --set-faulty /dev/sdb

# Vérifier l'état (le RAID doit continuer à fonctionner)
sudo mdadm --detail /dev/md0
cat /proc/mdstat

# Retirer le disque défaillant
sudo mdadm --manage /dev/md0 --remove /dev/sdb

# Ajouter un nouveau disque
sudo mdadm --manage /dev/md0 --add /dev/sde
```

---

## 📊 Maintenance et surveillance

### Surveillance automatique

```bash
# Configurer les notifications par email
sudo nano /etc/mdadm/mdadm.conf

# Ajouter :
MAILADDR admin@example.com

# Redémarrer le service de surveillance
sudo systemctl restart mdmonitor
```

### Vérification périodique

```bash
# Vérification mensuelle (premier dimanche)
echo "0 1 1-7 * 0 root /usr/share/mdadm/checkarray --cron --all --quiet" | sudo tee -a /etc/crontab

# Forcer une vérification manuelle
echo 'check' | sudo tee /sys/block/md0/md/sync_action
```

### Surveillance des performances

```bash
# Statistiques I/O en temps réel
iostat -x 1

# Monitoring spécifique RAID
sudo mdadm --monitor --scan --daemonise --mail=admin@example.com
```

---

## 🛠 Réinitialisation/Désinstallation

### Désinstallation propre

```bash
# 1. Démonter le système de fichiers
sudo umount /mnt/raid

# 2. Arrêter le RAID
sudo mdadm --stop /dev/md0

# 3. Supprimer la configuration
sudo mdadm --remove /dev/md0

# 4. Nettoyer les métadonnées des disques
sudo mdadm --zero-superblock /dev/sdb /dev/sdc

# 5. Supprimer de mdadm.conf
sudo nano /etc/mdadm/mdadm.conf
# (supprimer la ligne correspondant à md0)

# 6. Supprimer de fstab
sudo nano /etc/fstab
# (supprimer la ligne /dev/md0)

# 7. Mettre à jour initramfs
sudo update-initramfs -u
```

### Réinitialisation d'urgence

```bash
# Arrêter tous les RAID
sudo mdadm --stop --scan

# Nettoyer toutes les métadonnées
sudo mdadm --zero-superblock /dev/sd[b-z]

# Redémarrer si nécessaire
sudo reboot
```

---

## 🔧 Dépannage

### Problèmes courants

| Problème                    | Cause possible               | Solution                                         |
|-----------------------------|------------------------------|--------------------------------------------------|
| **RAID ne démarre pas**     | Configuration manquante      | Vérifier `/etc/mdadm/mdadm.conf`                 |
| **Disque marqué défaillant**| Erreurs I/O                  | Vérifier avec `dmesg` et remplacer si nécessaire |
| **Performance dégradée**    | Synchronisation en cours     | Attendre ou vérifier avec `/proc/mdstat`         |
| **Impossible de monter**    | Système de fichiers corrompu | Utiliser `fsck.ext4 /dev/md0`                    |

### Commandes de diagnostic

```bash
# Logs du système
sudo dmesg | grep -i raid
sudo journalctl -u mdmonitor

# État détaillé de tous les RAID
sudo mdadm --detail --scan

# Vérifier l'intégrité des disques
sudo badblocks -v /dev/sdb

# Test SMART des disques
sudo smartctl -a /dev/sdb
```

### Récupération de RAID endommagé

```bash
# Tenter de redémarrer un RAID
sudo mdadm --assemble /dev/md0 /dev/sdb /dev/sdc

# Forcer l'assemblage (attention !)
sudo mdadm --assemble --force /dev/md0 /dev/sdb /dev/sdc

# Reconstruire avec un disque manquant
sudo mdadm --assemble /dev/md0 /dev/sdb missing
```

---

## 💡 Bonnes pratiques

### 🛡️ Sécurité et fiabilité

> **📋 Recommandations importantes :**

- **Surveillance continue** : Configurer les alertes email pour mdadm
- **Sauvegardes régulières** : RAID ≠ sauvegarde !
- **Tests périodiques** : Vérifier l'intégrité mensuelle
- **Documentation** : Noter la configuration et les procédures
- **Disques de rechange** : Garder des disques de remplacement

### 📊 Optimisation

```bash
# Optimiser les performances (à adapter selon l'usage)
echo 'readahead' | sudo tee /sys/block/md0/queue/scheduler
echo 8192 | sudo tee /sys/block/md0/md/stripe_cache_size

# Optimiser pour SSD (si applicable)
echo noop | sudo tee /sys/block/md0/queue/scheduler
```

### 🔍 Monitoring avancé

```bash
# Script de surveillance personnalisé
#!/bin/bash
# /usr/local/bin/raid-check.sh

RAID_STATUS=$(cat /proc/mdstat | grep -c "UU")
if [ $RAID_STATUS -eq 0 ]; then
    echo "ALERTE: Problème RAID détecté" | mail -s "RAID Alert" admin@example.com
fi
```

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Prérequis](#prérequis)
- [→ Types RAID](#types-de-raid)
- [→ Création](#création-dun-raid)
- [→ Tests](#tests-et-vérifications)