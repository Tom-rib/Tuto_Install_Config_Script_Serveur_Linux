# Guide complet pour installer et configurer un serveur et client FTP/SFTP sur Linux

## 📋 Table des matières

- [Prérequis](#prérequis)
- [Installation serveur](#installation-serveur)
- [Configuration serveur](#configuration-serveur)
  - [Configuration vsftpd](#configuration-vsftpd)
  - [Création utilisateur FTP](#création-utilisateur-ftp)
  - [Configuration des répertoires](#configuration-des-répertoires)
- [Installation client](#installation-client)
- [Tests et vérifications](#tests-et-vérifications)
  - [Test FTP](#test-ftp)
  - [Test SFTP](#test-sftp)
- [Commandes utiles](#commandes-utiles)
- [Sécurisation et pare-feu](#sécurisation-et-pare-feu)
- [Notes importantes](#notes-importantes)

---

## ✅ Prérequis

- Système Linux (Debian/Ubuntu)
- Accès superutilisateur (`sudo`)
- Adresse IP fixe pour le serveur
- Ports ouverts dans le pare-feu : **21** (FTP), **22** (SFTP/SSH)

---

## 📥 Installation serveur

### 1. Mise à jour des paquets

```bash
sudo apt update
```

### 2. Installation du serveur FTP

```bash
sudo apt install vsftpd -y
```

### 3. Vérification du service

```bash
systemctl status vsftpd
```

> **✅ Vérifiez** que le service soit **active (running)**.

---

## ⚙️ Configuration serveur

### Configuration vsftpd

Éditez le fichier de configuration :

```bash
sudo nano /etc/vsftpd.conf
```

**Paramètres recommandés :**

```bash
# Autoriser l'écriture
write_enable=YES

# Isoler les utilisateurs dans leur répertoire home
chroot_local_user=YES

# Autoriser les connexions locales
local_enable=YES

# Configuration SSL (optionnel mais recommandé)
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
```

**Redémarrez le service :**

```bash
sudo systemctl restart vsftpd
```

### Création utilisateur FTP

```bash
sudo useradd -m ftpuser -s /bin/bash
sudo passwd ftpuser
```

> **📌 Information :**
> - `ftpuser` : nom de l'utilisateur
> - Saisissez le mot de passe choisi lors de l'invite

### Configuration des répertoires

```bash
sudo mkdir -p /home/ftpuser/ftp
sudo chown -R ftpuser:ftpuser /home/ftpuser/ftp
sudo chmod 755 /home/ftpuser/ftp
```

**Créer un dossier de test avec des fichiers :**

```bash
sudo mkdir /home/ftpuser/ftp/upload
sudo chown ftpuser:ftpuser /home/ftpuser/ftp/upload
echo "Fichier de test FTP" | sudo tee /home/ftpuser/ftp/test.txt
sudo chown ftpuser:ftpuser /home/ftpuser/ftp/test.txt
```

---

## 📥 Installation client

### Installation du client FTP/SFTP

```bash
sudo apt update
sudo apt install -y ftp openssh-client
```

**Outils inclus :**
- `ftp` → Client FTP classique
- `sftp` → Client SFTP sécurisé (via SSH)
- `scp` → Copie de fichiers sécurisée

---

## 🧪 Tests et vérifications

### Test FTP

**Connexion au serveur FTP :**

```bash
ftp 192.168.136.10
```

**Séquence de connexion :**
1. Login : `ftpuser`
2. Mot de passe : celui défini précédemment

**Commandes utiles FTP :**

```bash
ls              # Liste les fichiers
pwd             # Affiche le répertoire courant
cd dossier      # Change de répertoire
put fichier     # Envoie un fichier
get fichier     # Télécharge un fichier
mput *.txt      # Envoie plusieurs fichiers
mget *.txt      # Télécharge plusieurs fichiers
bye             # Quitte FTP
```

### Test SFTP

**Connexion au serveur SFTP (via SSH) :**

```bash
sftp ftpuser@192.168.136.10
```

**Commandes utiles SFTP :**

```bash
ls              # Liste les fichiers distants
lls             # Liste les fichiers locaux
pwd             # Répertoire distant
lpwd            # Répertoire local
put fichier     # Envoie un fichier
get fichier     # Télécharge un fichier
mkdir dossier   # Crée un répertoire distant
bye             # Quitte SFTP
```

---

## 🔧 Commandes utiles

| Commande | Description |
|----------|-------------|
| `systemctl status vsftpd` | Vérifie le service FTP |
| `systemctl restart vsftpd` | Redémarre le serveur FTP |
| `ftp IP_SERVEUR` | Connexion au serveur FTP |
| `sftp user@IP_SERVEUR` | Connexion SFTP (SSH) |
| `ls` | Liste les fichiers dans FTP/SFTP |
| `put fichier` | Envoie un fichier sur le serveur |
| `get fichier` | Télécharge un fichier depuis le serveur |

### Exemples pratiques

```bash
# Transfert de fichier via SFTP
sftp ftpuser@192.168.136.10
put /local/path/document.pdf
get /remote/path/fichier.txt

# Transfert via SCP (plus rapide pour fichiers uniques)
scp fichier.txt ftpuser@192.168.136.10:/home/ftpuser/ftp/

# Synchronisation avec rsync (recommandé pour gros volumes)
rsync -avz dossier/ ftpuser@192.168.136.10:/home/ftpuser/ftp/
```

---

## 🛡️ Sécurisation et pare-feu

### Ouverture des ports

**Avec UFW :**

```bash
sudo ufw allow 21/tcp    # FTP
sudo ufw allow 22/tcp    # SFTP/SSH
sudo ufw status
```

**Avec iptables :**

```bash
sudo iptables -A INPUT -p tcp --dport 21 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

### Configuration SSL pour vsftpd

**Générer un certificat SSL :**

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/vsftpd.pem \
    -out /etc/ssl/private/vsftpd.pem
```

**Ajouter dans `/etc/vsftpd.conf` :**

```bash
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
ssl_enable=YES
```

---

## 💡 Notes importantes

> **🔐 Recommandations de sécurité :**

- **Privilégiez SFTP** : Pour plus de sécurité, utilisez **SFTP uniquement** (via SSH) au lieu de FTP classique
- **Isolation des utilisateurs** : Le répertoire de l'utilisateur FTP est isolé grâce à `chroot_local_user=YES`
- **Vérification des ports** : Assurez-vous que les ports 21 (FTP) et 22 (SFTP) sont ouverts dans le pare-feu
- **Tests locaux** : Vous pouvez tester serveur et client sur la même machine pour vérification locale

### 🔍 Comparaison FTP vs SFTP

| Critère | FTP | SFTP |
|---------|-----|------|
| **Sécurité** | ❌ Non chiffré | ✅ Chiffré (SSH) |
| **Port** | 21 | 22 |
| **Authentification** | Mot de passe | Mot de passe + Clés SSH |
| **Transfert** | Binaire/ASCII | Binaire uniquement |
| **Recommandation** | Éviter | **Recommandé** |

### 🔧 Diagnostic en cas de problème

```bash
# Vérifier les logs FTP
sudo tail -f /var/log/vsftpd.log

# Vérifier les connexions actives
sudo ss -tlnp | grep :21

# Tester la connectivité
telnet 192.168.136.10 21

# Vérifier la configuration
sudo vsftpd -v
```

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Prérequis](#prérequis)
- [→ Installation](#installation-serveur)
- [→ Configuration](#configuration-serveur)
- [→ Tests](#tests-et-vérifications)