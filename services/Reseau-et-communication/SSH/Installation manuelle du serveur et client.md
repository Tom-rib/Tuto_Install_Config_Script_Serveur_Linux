# Guide complet pour installer et configurer SSH sur Linux

## 📋 Table des matières

- [Prérequis](#prérequis)
- [Installation du serveur SSH](#installation-du-serveur-ssh)
- [Configuration du serveur SSH](#configuration-du-serveur-ssh)
- [Génération et utilisation des clés SSH](#génération-et-utilisation-des-clés-ssh)
  - [Génération des clés](#génération-des-clés)
  - [Copie de la clé publique](#copie-de-la-clé-publique)
  - [Connexion avec clé](#connexion-avec-clé)
  - [Sécurisation par clé](#sécurisation-par-clé)
- [Installation du client SSH](#installation-du-client-ssh)
- [Connexion SSH](#connexion-ssh)
- [Tests et vérifications](#tests-et-vérifications)
- [Commandes utiles](#commandes-utiles)
- [Ouverture du port SSH](#ouverture-du-port-ssh)
- [Notes importantes](#notes-importantes)

---

## ✅ Prérequis

- Système Linux (Debian/Ubuntu)
- Accès superutilisateur (`sudo`)
- Un serveur et un client dans le même réseau (exemple : `192.168.136.X`)
- Le port **22** ouvert dans le pare-feu (ou autre port configuré)

---

## 📥 Installation du serveur SSH

### 1. Mise à jour des paquets

```bash
sudo apt update
```

### 2. Installation du serveur SSH

```bash
sudo apt install openssh-server -y
```

### 3. Vérification du service SSH

```bash
systemctl status ssh
```

> **✅ Vérifiez** que le service soit **active (running)**.

---

## ⚙️ Configuration du serveur SSH

Éditez le fichier principal de configuration :

```bash
sudo nano /etc/ssh/sshd_config
```

**Exemples de paramètres recommandés :**

```bash
Port 22
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
```

**Redémarrez le serveur pour appliquer les modifications :**

```bash
sudo systemctl restart ssh
```

---

## 🔑 Génération et utilisation des clés SSH

### Génération des clés

Générer une paire de clés sur le **client** :

```bash
ssh-keygen -t rsa -b 4096 -C "utilisateur@client"
```

> **📁 Emplacement par défaut :** Les clés sont stockées dans :
> - `~/.ssh/id_rsa` → Clé privée (ne jamais partager)
> - `~/.ssh/id_rsa.pub` → Clé publique (à copier sur le serveur)

### Copie de la clé publique

```bash
ssh-copy-id utilisateur@IP_SERVEUR
```

> **📌 Information :** Cette commande ajoute la clé publique dans `~/.ssh/authorized_keys` sur le serveur.

### Connexion avec clé

```bash
ssh -i ~/.ssh/id_rsa utilisateur@IP_SERVEUR

dans notre cas:

ssh -i ~/.ssh/client1 client1@192.168.136.140

```

> **🔐 Avantage :** Le serveur utilisera automatiquement la clé pour authentifier le client. Plus besoin de mot de passe si la clé est configurée.

### Sécurisation par clé

**Éditer `/etc/ssh/sshd_config` :**

```bash
PasswordAuthentication no
```

**Redémarrer le serveur :**

```bash
sudo systemctl restart ssh
```

---

## 📥 Installation du client SSH

### 1. Vérification/installation

```bash
ssh -V
```

Si `ssh` n'est pas installé :

```bash
sudo apt install openssh-client -y
```

### 2. Outils inclus

- `ssh` → Connexion au serveur
- `scp` → Copie de fichiers
- `sftp` → Interface de transfert sécurisé

---

## 🔗 Connexion SSH

### Connexion standard

```bash
ssh utilisateur@192.168.136.10
```

### Avec un port personnalisé

```bash
ssh -p 2222 utilisateur@192.168.136.10
```

---

## 🧪 Tests et vérifications

### 1. Vérifier si le serveur écoute

```bash
ss -lnpt | grep ssh
```

### 2. Connexion locale

```bash
ssh localhost
```

### 3. Connexion depuis un autre hôte

```bash
ssh utilisateur@192.168.136.10
```

---

## 🔧 Commandes utiles

| Commande                      | Description                                 |
|-------------------------------|---------------------------------------------|
| `systemctl status ssh`        | Vérifie si le serveur SSH fonctionne        |
| `systemctl restart ssh`       | Redémarre le service SSH                    |
| `ssh user@ip`                 | Se connecter à une machine distante         |
| `ssh -p PORT user@ip`         | Connexion via un port personnalisé          |
| `scp fichier user@ip:/chemin` | Copier un fichier vers le serveur           |
| `sftp user@ip`                | Interface SFTP pour transférer des fichiers |
| `ssh-keygen`                  | Générer une paire de clés SSH               |
| `ssh-copy-id user@ip`         | Copier sa clé publique vers le serveur      |

### Exemples pratiques

```bash
# Copier un fichier vers le serveur
scp document.txt user@192.168.136.10:/home/user/

# Copier un dossier complet
scp -r dossier/ user@192.168.136.10:/home/user/

# Connexion avec verbosité pour le debug
ssh -v user@192.168.136.10
```

---

## 🔓 Ouverture du port SSH

### Avec UFW (Ubuntu / Debian simple)

```bash
sudo ufw allow 22/tcp
sudo ufw status
```

### Avec nftables

```bash
sudo nft add rule inet filter input tcp dport 22 accept
sudo nft list ruleset
```

### Avec iptables

```bash
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables/rules.v4"
```

---

## 💡 Notes importantes

> **🔐 Bonnes pratiques de sécurité :**

- **Authentification par clé SSH** : Utilisez cette méthode pour plus de sécurité
- **Protection de la clé privée** : Ne jamais partager la clé privée (`id_rsa`)
- **Tests locaux** : Installer serveur et client sur la même machine est possible pour les tests
- **Ports personnalisés** : Si le port SSH est modifié, ouvrir le nouveau port dans le pare-feu

### 🛡️ Sécurisation avancée

```bash
# Limiter les tentatives de connexion
sudo fail2ban-client status sshd

# Changer le port par défaut
Port 2222

# Limiter les utilisateurs autorisés
AllowUsers user1 user2
```

### 🔍 Diagnostic en cas de problème

```bash
# Vérifier les logs SSH
sudo journalctl -u ssh

# Vérifier la configuration
sudo sshd -T

# Tester la connectivité réseau
telnet 192.168.136.10 22
```

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Prérequis](#prérequis)
- [→ Installation serveur](#installation-du-serveur-ssh)
- [→ Configuration](#configuration-du-serveur-ssh)
- [→ Clés SSH](#génération-et-utilisation-des-clés-ssh)