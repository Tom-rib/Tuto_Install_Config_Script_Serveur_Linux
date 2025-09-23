# Guide complet pour installer et configurer un serveur DNS Bind9 sur systèmes Linux

## 📋 Table des matières

- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
  - [Zones DNS](#zones-dns)
  - [Zone directe](#zone-directe)
  - [Zone inverse](#zone-inverse)
- [Vérification et tests](#vérification-et-tests)
- [Redémarrage du service](#redémarrage-du-service)
- [Commandes utiles](#commandes-utiles)
- [Notes importantes](#notes-importantes)

---

## ✅ Prérequis

- Système Linux (Debian 12 ou Ubuntu)
- Accès superutilisateur (sudo)
- Adresse IP fixe pour le serveur DNS : `192.168.136.253`
- Clients configurés pour pointer vers ce serveur DNS

---

## 📥 Installation

### 1. Mise à jour des paquets

```bash
sudo apt update
```

### 2. Installation de Bind9 et utilitaires

```bash
sudo apt install bind9 bind9-utils bind9-dnsutils -y
```

---

## ⚙️ Configuration

### Zones DNS

Éditez le fichier `/etc/bind/named.conf.local` pour déclarer les zones :

```bash
sudo nano /etc/bind/named.conf.local
```

Ajoutez la configuration suivante :

```bash
zone "tutoserveurs.local" {
    type master;
    file "/etc/bind/db.tutoserveurs.local";
};

zone "136.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.168.136";
};
```

### Zone directe

Créez le fichier de zone directe :

```bash
sudo cp /etc/bind/db.local /etc/bind/db.tutoserveurs.local
sudo nano /etc/bind/db.tutoserveurs.local
```

**Exemple de contenu :**

```dns
$TTL    604800
@       IN      SOA     ns1.tutoserveurs.local. admin.tutoserveurs.local. (
                        2         ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL

; Serveurs DNS
@       IN      NS      ns1.tutoserveurs.local.

; Enregistrements A
ns1     IN      A       192.168.136.253
serveur1 IN     A       192.168.136.254
client1 IN      A       192.168.136.10
client2 IN      A       192.168.136.11
```

### Zone inverse

Créez le fichier de zone inverse :

```bash
sudo cp /etc/bind/db.127 /etc/bind/db.192.168.136
sudo nano /etc/bind/db.192.168.136
```

**Exemple de contenu :**

```dns
$TTL    604800
@       IN      SOA     ns1.tutoserveurs.local. admin.tutoserveurs.local. (
                        1         ; Serial
                        604800    ; Refresh
                        86400     ; Retry
                        2419200   ; Expire
                        604800 )  ; Negative Cache TTL

; Serveurs DNS
@       IN      NS      ns1.tutoserveurs.local.

; Résolution inverse
253     IN      PTR     ns1.tutoserveurs.local.
254     IN      PTR     serveur1.tutoserveurs.local.
10      IN      PTR     client1.tutoserveurs.local.
11      IN      PTR     client2.tutoserveurs.local.
```

---

## 🧪 Vérification et tests

### Vérification de la configuration

```bash
sudo named-checkconf
sudo named-checkzone tutoserveurs.local /etc/bind/db.tutoserveurs.local
sudo named-checkzone 136.168.192.in-addr.arpa /etc/bind/db.192.168.136
```

### Tests de résolution

**Résolution directe et inverse :**

```bash
dig @192.168.136.253 serveur1.tutoserveurs.local
dig @192.168.136.253 -x 192.168.136.254
nslookup client1.tutoserveurs.local 192.168.136.253
nslookup 192.168.136.10 192.168.136.253
```

---

## 🔄 Redémarrage du service

```bash
sudo systemctl restart bind9
sudo systemctl enable bind9
```

---

## 🔧 Commandes utiles

| Commande | Description |
|----------|-------------|
| `sudo systemctl status bind9` | Vérifier l'état du service |
| `sudo journalctl -xeu bind9` | Consulter les logs détaillés en cas d'erreur |
| `named-checkconf` | Vérifier la configuration globale |
| `named-checkzone <zone> <fichier>` | Vérifier une zone spécifique |
| `dig @127.0.0.1 <nom>` | Tester la résolution locale |
| `rndc reload` | Recharger la configuration DNS |

---

## 💡 Notes importantes

> **⚠️ Points importants à retenir :**

- **Incrémentez toujours le Serial** dans les fichiers de zone après modification
- **Ajoutez un DNS secondaire** pour la redondance si nécessaire
- **Les clients doivent utiliser** `192.168.136.253` comme serveur DNS primaire (configuré via DHCP ou manuellement)

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Prérequis](#prérequis)
- [→ Installation](#installation)
- [→ Configuration](#configuration)
- [→ Tests](#vérification-et-tests)