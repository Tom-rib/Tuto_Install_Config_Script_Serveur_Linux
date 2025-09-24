# 🔥 Firewall Interactif (iptables / nftables)

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Fonctionnement du script](#fonctionnement-du-script)
- [Installation et utilisation](#installation-et-utilisation)
- [Menu principal](#menu-principal)
- [Ports et services supportés](#ports-et-services-supportés)
- [Exemple de session interactive](#exemple-de-session-interactive)
- [Tests et vérifications](#tests-et-vérifications)
- [Configuration avancée](#configuration-avancée)
- [Désinstallation](#désinstallation)
- [Dépannage](#dépannage)
- [Notes importantes](#notes-importantes)

---

## 🎯 Vue d'ensemble

Ce script **interactif** permet de configurer facilement un pare-feu robuste sous Linux avec iptables et nftables. Il offre une approche **restrictive par défaut** en bloquant tout le trafic non autorisé, puis ouvre uniquement les services nécessaires.

### ✨ Fonctionnalités principales

- Configuration **zero-trust** (tout bloqué par défaut)
- Support **WAN/LAN** avec NAT automatique
- **20+ services prédéfinis** (SSH, DNS, Web, Mail, etc.)
- **Tests intégrés** de connectivité
- **Sauvegarde automatique** des règles

---

## 🚀 Fonctionnement du script

Ce script permet de :

- ✅ **Installer** iptables + nftables
- ✅ **Configurer** automatiquement un pare-feu restrictif
- ✅ **Ouvrir** uniquement les services choisis (SSH, DNS, DHCP, HTTP, HTTPS, FTP, LDAP, NFS, etc.)
- ✅ **Activer** NAT/forwarding si besoin (WAN ↔ LAN)
- ✅ **Tester** les règles appliquées
- ✅ **Désinstaller** / réinitialiser (remettre tout en ACCEPT)

---

## ⚙️ Installation et utilisation

### Prérequis

- Système Linux (Debian/Ubuntu/CentOS)
- Accès `sudo`
- Interfaces réseau configurées

### Lancement du script

```bash
# Rendre le script exécutable
sudo chmod +x firewall_interactif.sh

# Lancer le script
sudo ./firewall_interactif.sh
```

---

## 🛠️ Menu principal

```
🔥 FIREWALL INTERACTIF - MENU PRINCIPAL

1. 🛡️  Installer/configurer le firewall
2. 🧪 Tester les règles actives
3. 🔄 Réinitialiser/Désinstaller
4. ❌ Quitter

Votre choix [1-4] :
```

### Options détaillées

| Option | Description | Actions |
|--------|-------------|---------|
| **1** | Installation/Configuration | Configure le firewall, choisit les services, active le NAT |
| **2** | Tests | Vérifie les règles, teste la connectivité |
| **3** | Réinitialisation | Supprime toutes les règles, remet en mode ACCEPT |
| **4** | Quitter | Sort du script proprement |

---

## 📡 Ports et services supportés

| Service | Ports ouverts | Description |
|---------|---------------|-------------|
| **SSH** | 22/tcp | Administration distante |
| **DNS** | 53/tcp, 53/udp | Résolution de noms |
| **DHCP** | 67-68/udp | Attribution IP automatique |
| **HTTP** | 80/tcp | Serveur web |
| **HTTPS** | 443/tcp | Serveur web sécurisé |
| **FTP** | 21/tcp | Transfert de fichiers |
| **SFTP** | 22/tcp (via SSH) | Transfert sécurisé |
| **Samba** | 137-139/tcp+udp, 445/tcp+udp | Partage Windows |
| **NFS** | 2049/tcp+udp | Partage Linux |
| **MySQL/MariaDB** | 3306/tcp | Base de données |
| **PostgreSQL** | 5432/tcp | Base de données |
| **LDAP** | 389/tcp+udp | Annuaire |
| **LDAPS** | 636/tcp | Annuaire sécurisé |
| **OpenVPN** | 1194/udp | VPN |
| **WireGuard** | 51820/udp | VPN moderne |
| **VOIP (Asterisk)** | 5060/udp, 10000-20000/udp | Téléphonie IP |
| **Mail (SMTP/IMAP/POP)** | 25, 143, 993, 110, 995/tcp | Serveur mail |
| **Autres** | Port choisi par l'utilisateur | Service personnalisé |

---

## 🎬 Exemple de session interactive

### Configuration d'un serveur web avec NAT

```bash
$ sudo ./firewall_interactif.sh

🔥 FIREWALL INTERACTIF - MENU PRINCIPAL
1. 🛡️  Installer/configurer le firewall

Votre choix [1-4] : 1

📡 CONFIGURATION RÉSEAU
Interface LAN détectée : ens33 (192.168.136.10)
Interface WAN détectée : ens34 (192.168.1.100)

Configurer le NAT WAN→LAN ? [o/N] : o
✅ NAT configuré : ens34 → ens33

🚪 SÉLECTION DES SERVICES
Services disponibles :
1) SSH (22/tcp)           2) DNS (53/tcp+udp)
3) DHCP (67-68/udp)      4) HTTP (80/tcp)
5) HTTPS (443/tcp)       6) FTP (21/tcp)
...

Choisissez les services (ex: 1,4,5) : 1,4,5

✅ Services sélectionnés :
- SSH (22/tcp)
- HTTP (80/tcp)
- HTTPS (443/tcp)

🛡️ APPLICATION DES RÈGLES
⏳ Configuration du firewall...
✅ Règles iptables appliquées
✅ Règles nftables appliquées
✅ Configuration sauvegardée

🧪 TEST AUTOMATIQUE
✅ SSH accessible (port 22)
✅ HTTP accessible (port 80)
✅ HTTPS accessible (port 443)
❌ Port 21 bloqué (normal)

Configuration terminée ! 🎉
```

### Ajout d'un service personnalisé

```bash
🚪 SÉLECTION DES SERVICES
...
18) Service personnalisé

Choisissez les services : 1,18

Port personnalisé à ouvrir : 8080
Protocole [tcp/udp/both] : tcp

✅ Service personnalisé ajouté : 8080/tcp
```

---

## 🧪 Tests et vérifications

### Tests intégrés du script

Le script inclut des tests automatiques :

```bash
# Option 2 du menu principal
🧪 TESTS DES RÈGLES ACTIVES

📊 Règles iptables :
Chain INPUT (policy DROP)
target     prot opt source      destination
ACCEPT     tcp  --  anywhere    anywhere    tcp dpt:ssh
ACCEPT     tcp  --  anywhere    anywhere    tcp dpt:http
...

📊 Test de connectivité :
✅ Port 22 (SSH) : OUVERT
✅ Port 80 (HTTP) : OUVERT
❌ Port 21 (FTP) : FERMÉ
```

### Tests manuels

```bash
# Voir toutes les règles iptables
sudo iptables -L -n -v

# Voir les règles NAT
sudo iptables -t nat -L -n -v

# Tester un port depuis l'extérieur
nc -zv <IP_SERVEUR> 22

# Vérifier les connexions actives
ss -tlnp
```

### Logs et monitoring

```bash
# Consulter les logs du firewall
sudo journalctl -f | grep -i iptables

# Statistiques des règles
sudo iptables -L -n -v --line-numbers
```

---

## ⚙️ Configuration avancée

### Personnalisation des règles

Le script génère des fichiers de configuration :

```bash
# Règles iptables sauvegardées
/etc/iptables/rules.v4
/etc/iptables/rules.v6

# Script de démarrage
/etc/systemd/system/firewall-custom.service
```

### Modification manuelle

```bash
# Éditer les règles personnalisées
sudo nano /etc/iptables/rules.v4

# Recharger les règles
sudo systemctl restart firewall-custom
```

### Règles par défaut appliquées

```bash
# Politique restrictive
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Autoriser loopback
iptables -A INPUT -i lo -j ACCEPT

# Autoriser connexions établies
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Anti-DDoS basique
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: "
```

---

## 🔄 Désinstallation

### Réinitialisation complète

```bash
# Via le script (recommandé)
sudo ./firewall_interactif.sh
# Choisir option 3

# Ou manuellement
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F
sudo iptables -t nat -F
```

### Suppression des services

```bash
# Désactiver le service personnalisé
sudo systemctl disable firewall-custom
sudo systemctl stop firewall-custom

# Supprimer les fichiers de configuration
sudo rm -f /etc/iptables/rules.*
sudo rm -f /etc/systemd/system/firewall-custom.service
```

---

## 🔧 Dépannage

### Problèmes courants

| Problème | Cause possible | Solution |
|----------|----------------|----------|
| **Connexion SSH perdue** | Port 22 bloqué | Accès console physique requis |
| **Internet ne fonctionne plus** | Politique DROP trop restrictive | Vérifier règles OUTPUT |
| **NAT ne fonctionne pas** | Forwarding désactivé | `echo 1 > /proc/sys/net/ipv4/ip_forward` |
| **Services inaccessibles** | Règles mal appliquées | Vérifier avec `iptables -L` |

### Mode de récupération

```bash
# En cas de perte de connexion SSH
# Accès console physique nécessaire

# Réinitialisation d'urgence
sudo iptables -P INPUT ACCEPT
sudo iptables -F

# Redémarrage complet
sudo systemctl reboot
```

### Diagnostic complet

```bash
# Vérifier les interfaces
ip addr show

# Vérifier le routage
ip route show

# Tester la connectivité locale
ping -c 3 127.0.0.1

# Vérifier les processus réseau
sudo ss -tlnp
```

---

## 💡 Notes importantes

### ⚠️ Avertissements de sécurité

> **🔒 Recommandations critiques :**

- **Toujours garder SSH ouvert** lors de la configuration distante
- **Tester depuis une console locale** avant déploiement
- **Sauvegarder la configuration** avant modification
- **Prévoir un accès physique** en cas de problème

### 🎯 Bonnes pratiques

- **Principe du moindre privilège** : Ouvrir uniquement les ports nécessaires
- **Logs et monitoring** : Surveiller les tentatives d'accès
- **Mise à jour régulière** : Maintenir le système à jour
- **Tests périodiques** : Vérifier les règles régulièrement

### 📊 Architecture recommandée

```
Internet
    |
[Firewall WAN] (iptables/nftables)
    |
[DMZ Services] (80, 443, 25, etc.)
    |
[Internal LAN] (SSH, DHCP, DNS, etc.)
```

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Installation](#installation-et-utilisation)
- [→ Services](#ports-et-services-supportés)
- [→ Configuration](#exemple-de-session-interactive)
- [→ Tests](#tests-et-vérifications)