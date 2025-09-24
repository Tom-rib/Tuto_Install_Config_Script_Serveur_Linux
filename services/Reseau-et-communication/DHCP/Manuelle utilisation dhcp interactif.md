# 📘 Guide d'utilisation – Script DHCP interactif

## 📋 Table des matières

- [Introduction](#introduction)
- [Prérequis](#prérequis)
- [Fonctionnement du script](#fonctionnement-du-script)
- [Modes disponibles](#modes-disponibles)
- [Utilisation pas à pas](#utilisation-pas-à-pas)
  - [Installation serveur DHCP](#1️⃣-installation-serveur-dhcp)
  - [Installation client DHCP](#2️⃣-installation-client-dhcp)
  - [Test DHCP](#3️⃣-test-dhcp)
  - [Désinstallation DHCP](#4️⃣-désinstallation-dhcp)
- [Tests et vérifications](#tests-et-vérifications)
- [Rappels sur DHCP](#rappels-sur-dhcp)
- [Notes techniques](#notes-techniques)

---

## 📖 Introduction

Ce script **interactif** permet de gérer facilement un service DHCP sous Linux (Debian/Ubuntu). Il offre plusieurs modes : installation serveur, installation client, tests et désinstallation.

Il prend aussi en charge une **seconde interface réseau** :
- En mode **WAN** : configure un DNS Google (8.8.8.8) et active le NAT/forwarding pour partager Internet avec le LAN
- En mode **LAN** : ajoute un deuxième sous-réseau DHCP

---

## ✅ Prérequis

- Debian 12/Ubuntu ou dérivé
- Accès `sudo`
- Interfaces réseau disponibles (exemple : `ens33` pour LAN, `ens34` pour WAN)

---

## ⚙️ Fonctionnement du script

Le script effectue les opérations suivantes :

1. **Collecte des informations** réseau (interface, sous-réseau, plage IP)
2. **Configuration automatique** du fichier `/etc/dhcp/dhcpd.conf`
3. **Configuration NAT** optionnelle si une interface WAN est choisie
4. **Tests rapides** du DHCP avec un client

### 💡 Nouveauté : Saisie simplifiée

Il est possible de ne saisir que **le dernier octet de l'IP** (`X`). 

**Exemple :**
```
Base réseau : 192.168.136
Adresse IP routeur : X=254 → 192.168.136.254
Plage DHCP : X=100 à X=200 → 192.168.136.100 → 192.168.136.200
```

---

## 🛠️ Modes disponibles

Lorsque vous lancez le script :

```bash
sudo ./dhcp_interactif.sh
```

Un menu interactif apparaît :

1. **Installer serveur DHCP**
2. **Installer client DHCP**
3. **Tester DHCP**
4. **Désinstaller DHCP**
5. **Quitter**

---

## 🚀 Utilisation pas à pas

### 1️⃣ Installation serveur DHCP

**Étapes de configuration :**

1. **Choisir l'interface LAN** (par ex. `ens33`)
2. **Indiquer la base réseau** (ex : `192.168.136`)
3. **Saisir uniquement le dernier octet** pour :
   - Passerelle (`254`) → devient `192.168.136.254`
   - Plage IP (`100-200`) → devient `192.168.136.100 - 192.168.136.200`

### ⚡ Option : Seconde interface

**Ajouter une seconde interface WAN/LAN :**
- **WAN** → NAT activé + DNS Google
- **LAN** → nouvelle plage DHCP

### 2️⃣ Installation client DHCP

- Installation de `isc-dhcp-client`
- Demande d'IP sur une interface choisie (ex: `eth0`)

### 3️⃣ Test DHCP

Le script effectue :
- **Vérification** de l'adresse IP actuelle
- **Relance** d'une demande DHCP (`dhclient -v`)
- **Affichage** des derniers baux reçus

### 4️⃣ Désinstallation DHCP

Suppression complète :
- **Serveur DHCP** et/ou **client DHCP**
- Fichiers de configuration associés

---

## 🔍 Tests et vérifications

### Test côté client

Sur un **client DHCP** (ou le serveur lui-même avec une interface en DHCP) :

```bash
sudo dhclient -v eth0
ip addr show eth0
```

### Vérification des baux

Pour vérifier les baux sur le serveur :

```bash
cat /var/lib/dhcp/dhcpd.leases
```

### Diagnostic réseau

```bash
# Vérifier le service DHCP
sudo systemctl status isc-dhcp-server

# Consulter les logs
sudo journalctl -u isc-dhcp-server

# Vérifier les interfaces
ip link show
```

---

## 📘 Rappels sur DHCP

### Principe de fonctionnement

- **DHCP** (Dynamic Host Configuration Protocol) attribue automatiquement :
  - Adresse IP
  - Masque de sous-réseau
  - Passerelle par défaut
  - Serveurs DNS

### Points importants

| Aspect          | Description                                                               |
|-----------------|---------------------------------------------------------------------------|
| **Unicité**     | Le serveur doit être **unique** par réseau (sinon conflits)               |
| **WAN/LAN**     | Un **WAN** reçoit l'IP via DHCP/Static → NAT redirige vers le LAN         |
| **Plages IP**   | Les **plages IP** doivent être dans le même sous-réseau que la passerelle |
| **Attribution** | Les IP sont attribuées dynamiquement selon la plage définie               |

### Processus DHCP (DORA)

1. **Discover** : Le client cherche un serveur DHCP
2. **Offer** : Le serveur propose une configuration IP
3. **Request** : Le client demande cette configuration
4. **Acknowledge** : Le serveur confirme l'attribution

---

## 💡 Notes techniques

### Configuration et stockage

- **Sauvegarde** de la config dans `/etc/dhcp/dhcpd.conf`
- **NAT** utilise `iptables` + `netfilter-persistent`
- **Logs** disponibles dans `/var/log/syslog`

### Recommandations

> **🎯 Bonnes pratiques :**

- **IP fixes pour les serveurs** (DNS, routeurs, serveurs critiques)
- **DHCP pour les clients** (postes de travail, appareils mobiles)
- **Plages séparées** pour différents types d'équipements
- **Sauvegarde régulière** de la configuration

### Architecture réseau type

```
Internet
    |
[Routeur WAN] (192.168.1.0/24)
    |
[Serveur DHCP] (192.168.136.254)
    |
[Switch LAN] (192.168.136.0/24)
    |
[Clients DHCP] (192.168.136.100-200)
```

### Dépannage courant

| Problème | Solution |
|----------|----------|
| **Pas d'IP attribuée** | Vérifier les interfaces et les plages |
| **Conflit DHCP** | S'assurer qu'un seul serveur DHCP existe |
| **NAT non fonctionnel** | Vérifier les règles iptables |
| **DNS ne répond pas** | Contrôler la configuration DNS |

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Introduction](#introduction)
- [→ Prérequis](#prérequis)
- [→ Modes disponibles](#modes-disponibles)
- [→ Utilisation](#utilisation-pas-à-pas)