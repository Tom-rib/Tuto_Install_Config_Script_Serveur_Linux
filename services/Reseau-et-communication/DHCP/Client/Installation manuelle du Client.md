# 🌐 Client DHCP - Guide d'Installation

Guide complet pour installer et configurer un client DHCP sur systèmes Linux.

## 📋 Sommaire
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Tests](#tests)
- [Commandes Utiles](#commandes-utiles)

## ✅ Prérequis
- Système Linux (Debian/Ubuntu)
- Accès superutilisateur (sudo)
- Interface réseau configurable

## 📥 Installation

### 1. Mise à jour des paquets

bash

sudo apt update

### 2. Installation du client DHCP

bash
sudo apt install isc-dhcp-client -y


## ⚙️ Configuration

### 3. Configuration de l'interface réseau

Éditez le fichier de configuration :

bash
sudo nano /etc/network/interfaces
Ajoutez/modifiez la configuration (exemple pour eth0) :

bash
auto eth0
iface eth0 inet dhcp

### 4. Redémarrage du service réseau

bash
sudo systemctl restart networking

## 🧪 Tests

Obtenir une IP manuellement

bash
sudo dhclient -v eth0

Vérifier l'adresse IP attribuée

bash

ip addr show eth0

## 🔧 Commandes Utiles

Commande	Description

sudo dhclient -r eth0	Libère l'IP actuelle

ip link show	Liste les interfaces réseau

systemctl status networking	Statut du service réseau

## 💡 Notes

Remplacez eth0 par votre interface réseau

Le redémarrage du service est nécessaire après configuration

Utilisez -v pour le mode verbeux et voir les détails
