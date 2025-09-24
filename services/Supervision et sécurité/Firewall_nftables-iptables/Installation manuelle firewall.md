# 🔥 Firewall (iptables / nftables) – Installation manuelle

## 📋 Table des matières

- [Rappel de fonctionnement](#rappel-de-fonctionnement)
- [Installation des outils](#installation-des-outils)
- [Configuration avec iptables](#configuration-avec-iptables)
  - [Réinitialisation des règles](#1️⃣-réinitialiser-les-règles)
  - [Politiques par défaut](#2️⃣-politiques-par-défaut)
  - [Règles de base](#3️⃣-règles-de-base)
  - [Ports et services courants](#ports-et-services-courants)
  - [NAT et Forward](#nat-et-forward)
  - [Sauvegarde iptables](#sauvegarde-iptables)
  - [Tests iptables](#tests-iptables)
  - [Réinitialisation iptables](#réinitialisation-iptables)
- [Configuration avec nftables](#configuration-avec-nftables)
  - [Réinitialisation nftables](#1️⃣-réinitialiser-la-configuration)
  - [Configuration nftables](#2️⃣-exemple-de-configuration)
  - [Sauvegarde nftables](#sauvegarde-nftables)
  - [Tests nftables](#tests-nftables)
  - [Réinitialisation nftables](#réinitialisation-nftables)
- [Comparaison iptables vs nftables](#comparaison-iptables-vs-nftables)

---

## 📖 Rappel de fonctionnement

Un pare-feu filtre le trafic réseau selon des règles définies.

### Chaînes principales

| Chaîne | Description |
|--------|-------------|
| **INPUT** | Trafic entrant vers la machine |
| **OUTPUT** | Trafic sortant depuis la machine |
| **FORWARD** | Trafic traversant la machine (routeur/passerelle) |

### Politiques par défaut

> **👉 Actions possibles :**
> - **DROP** = bloquer le trafic
> - **ACCEPT** = autoriser le trafic
> - **REJECT** = rejeter avec notification

---

## 🚀 Installation des outils

```bash
sudo apt update
sudo apt install -y iptables nftables netfilter-persistent iptables-persistent
```

**Paquets installés :**
- `iptables` : Firewall traditionnel Linux
- `nftables` : Nouveau framework de filtrage
- `netfilter-persistent` : Sauvegarde automatique des règles
- `iptables-persistent` : Persistance des règles iptables

---

## ⚙️ Configuration avec iptables

### 1️⃣ Réinitialiser les règles

```bash
sudo iptables -F      # Vider les chaînes
sudo iptables -X      # Supprimer les chaînes personnalisées
sudo iptables -t nat -F    # Vider la table NAT
sudo iptables -t nat -X    # Supprimer chaînes NAT personnalisées
```

### 2️⃣ Politiques par défaut

```bash
sudo iptables -P INPUT DROP      # Bloquer entrant par défaut
sudo iptables -P FORWARD DROP    # Bloquer transit par défaut  
sudo iptables -P OUTPUT ACCEPT   # Autoriser sortant par défaut
```

> **⚠️ Attention :** Ces règles bloquent tout le trafic entrant. Assurez-vous d'avoir un accès physique à la machine !

### 3️⃣ Règles de base

#### Connexions déjà établies

```bash
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
```

#### Interface localhost

```bash
sudo iptables -A INPUT -i lo -j ACCEPT
```

---

## 📡 Ports et services courants

### SSH (22/tcp)

```bash
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

### DNS (53/tcp,udp)

```bash
sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 53 -j ACCEPT
```

### DHCP (67-68/udp)

```bash
sudo iptables -A INPUT -p udp --dport 67:68 -j ACCEPT
```

### HTTP/HTTPS (80,443/tcp)

```bash
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

### FTP (21/tcp)

```bash
sudo iptables -A INPUT -p tcp --dport 21 -j ACCEPT
```

### Samba (137-139,445)

```bash
sudo iptables -A INPUT -p udp --dport 137:139 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 137:139 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 445 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 445 -j ACCEPT
```

### NFS (2049/tcp,udp)

```bash
sudo iptables -A INPUT -p tcp --dport 2049 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 2049 -j ACCEPT
```

### MySQL/MariaDB (3306/tcp)

```bash
sudo iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
```

### LDAP (389/tcp,udp)

```bash
sudo iptables -A INPUT -p tcp --dport 389 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 389 -j ACCEPT
```

---

## 🌍 NAT et Forward

### Activer IP forwarding

```bash
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p
```

### Configuration NAT

**Exemple WAN (eth0) vers LAN (eth1) :**

```bash
# NAT pour partage Internet
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Autoriser forward LAN → WAN
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

# Autoriser retour WAN → LAN (connexions établies)
sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT
```

---

## 💾 Sauvegarde iptables

```bash
# Sauvegarder les règles actuelles
sudo netfilter-persistent save

# Recharger les règles sauvegardées
sudo netfilter-persistent reload
```

**Fichiers de sauvegarde :**
- `/etc/iptables/rules.v4` (IPv4)
- `/etc/iptables/rules.v6` (IPv6)

---

## 🧪 Tests iptables

### Vérification des règles

```bash
# Afficher toutes les règles
sudo iptables -L -n -v

# Afficher les règles NAT
sudo iptables -t nat -L -n -v

# Afficher avec numéros de ligne
sudo iptables -L --line-numbers
```

### Test de connectivité

```bash
# Tester un port ouvert
nc -zv <IP_SERVEUR> 22

# Vérifier NAT/Internet
ping -c 4 8.8.8.8

# Scanner les ports ouverts
nmap -sS <IP_SERVEUR>
```

---

## 🛠 Réinitialisation iptables

```bash
# Supprimer toutes les règles
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X

# Remettre les politiques en ACCEPT
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT

# Sauvegarder l'état "ouvert"
sudo netfilter-persistent save
```

---

## ⚙️ Configuration avec nftables

### 1️⃣ Réinitialiser la configuration

```bash
sudo systemctl stop nftables
sudo bash -c "echo '' > /etc/nftables.conf"
```

### 2️⃣ Exemple de configuration

**Éditer le fichier de configuration :**

```bash
sudo nano /etc/nftables.conf
```

**Exemple de configuration complète :**

```bash
#!/usr/sbin/nft -f

# Supprimer les règles existantes
flush ruleset

# Table principale pour IPv4 et IPv6
table inet filter {
    # Chaîne INPUT (trafic entrant)
    chain input {
        type filter hook input priority 0;
        policy drop;  # Politique restrictive par défaut

        # Interface loopback
        iif lo accept

        # Connexions établies et liées
        ct state established,related accept

        # SSH (administration)
        tcp dport 22 accept

        # DNS (résolution de noms)
        udp dport 53 accept
        tcp dport 53 accept

        # Services web
        tcp dport {80, 443} accept

        # DHCP (si serveur DHCP)
        udp dport {67, 68} accept

        # FTP
        tcp dport 21 accept

        # Samba/CIFS
        tcp dport {139, 445} accept
        udp dport {137, 138, 445} accept

        # NFS
        tcp dport 2049 accept
        udp dport 2049 accept

        # Bases de données
        tcp dport 3306 accept  # MySQL
        tcp dport 5432 accept  # PostgreSQL

        # LDAP
        tcp dport 389 accept
        udp dport 389 accept
        tcp dport 636 accept   # LDAPS
    }

    # Chaîne FORWARD (routage)
    chain forward {
        type filter hook forward priority 0;
        policy drop;

        # Exemple NAT : autoriser LAN → WAN
        iifname "eth1" oifname "eth0" accept
        iifname "eth0" oifname "eth1" ct state established,related accept
    }

    # Chaîne OUTPUT (trafic sortant)
    chain output {
        type filter hook output priority 0;
        policy accept;  # Autoriser tout le trafic sortant
    }
}

# Table NAT pour le partage Internet
table inet nat {
    chain postrouting {
        type nat hook postrouting priority 100;
        
        # NAT sur interface WAN
        oifname "eth0" masquerade
    }
}
```

---

## 💾 Sauvegarde nftables

```bash
# Activer et démarrer nftables
sudo systemctl enable nftables
sudo systemctl start nftables

# Vérifier le statut
sudo systemctl status nftables
```

**Fichier de configuration :** `/etc/nftables.conf`

---

## 🧪 Tests nftables

### Vérification des règles

```bash
# Afficher toutes les règles
sudo nft list ruleset

# Afficher une table spécifique
sudo nft list table inet filter

# Afficher les tables existantes
sudo nft list tables

# Statistiques des règles
sudo nft list ruleset -a
```

### Test de connectivité

```bash
# Tester accès à un service
nc -zv <IP_SERVEUR> 22

# Vérifier les connexions
ss -tlnp

# Test du NAT
ping -c 4 8.8.8.8
```

---

## 🛠 Réinitialisation nftables

```bash
# Supprimer toutes les règles
sudo nft flush ruleset

# Arrêter le service
sudo systemctl stop nftables

# Désactiver au démarrage (optionnel)
sudo systemctl disable nftables

# Vider le fichier de configuration
sudo bash -c "echo '' > /etc/nftables.conf"
```

---

## 🔄 Comparaison iptables vs nftables

| Critère | iptables | nftables |
|---------|----------|----------|
| **Syntaxe** | Complexe, multiple commandes | Unifié, plus lisible |
| **Performance** | Bonne | Meilleure (moins de règles dupliquées) |
| **Configuration** | Commandes successives | Fichier de configuration unique |
| **IPv4/IPv6** | Séparé (iptables/ip6tables) | Unifié (inet) |
| **Atomicité** | Non | Oui (changements atomiques) |
| **Compatibilité** | Ancien standard | Nouveau standard (Linux 3.13+) |
| **Recommandation** | Legacy, encore très utilisé | **Recommandé pour nouvelles installations** |

### Migration iptables → nftables

```bash
# Traduire règles iptables existantes
sudo iptables-save > /tmp/iptables-rules
sudo iptables-restore-translate -f /tmp/iptables-rules > /tmp/nftables-rules

# Appliquer les nouvelles règles
sudo nft -f /tmp/nftables-rules
```

---

## 💡 Bonnes pratiques

### 🛡️ Sécurité

- **Toujours garder SSH ouvert** lors de configuration distante
- **Tester depuis console locale** avant mise en production  
- **Principe du moindre privilège** : ouvrir uniquement le nécessaire
- **Logs et monitoring** : surveiller les tentatives d'intrusion

### 📊 Organisation

```bash
# Exemple de structure nftables organisée
table inet filter {
    # Variables pour faciliter la maintenance
    define SSH_PORT = 22
    define WEB_PORTS = {80, 443}
    define DB_PORTS = {3306, 5432}
    
    chain input {
        type filter hook input priority 0;
        policy drop;
        
        # Règles de base
        iif lo accept
        ct state established,related accept
        
        # Services par catégorie
        tcp dport $SSH_PORT accept        # Administration
        tcp dport $WEB_PORTS accept       # Web
        tcp dport $DB_PORTS accept        # Bases de données
    }
}
```

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Installation](#installation-des-outils)
- [→ iptables](#configuration-avec-iptables)
- [→ nftables](#configuration-avec-nftables)
- [→ Comparaison](#comparaison-iptables-vs-nftables)