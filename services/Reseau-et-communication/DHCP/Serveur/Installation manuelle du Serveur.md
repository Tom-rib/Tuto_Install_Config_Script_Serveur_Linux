# 🌐 Serveur DHCP - Guide d'Installation Complète

Guide complet pour installer et configurer un serveur DHCP avec **isc-dhcp-server** sur systèmes Linux.

## 📋 Table des Matières
- [Présentation](#présentation)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Gestion du Service](#gestion-du-service)
- [Dépannage](#dépannage)
- [Commandes Utiles](#commandes-utiles)

## 🚀 Présentation
Ce projet permet de déployer un serveur DHCP qui attribue automatiquement des adresses IP aux clients du réseau.

## ✅ Prérequis
- Système Linux (Debian/Ubuntu)
- Accès superutilisateur (sudo)
- Interface réseau configurée en mode statique ou bridge

## 📥 Installation

### 1. Mise à jour des paquets

bash
sudo apt update

###  2. Installation du serveur DHCP

bash
sudo apt install isc-dhcp-server -y

## ⚙️ Configuration

### 3. Configuration de l'interface d'écoute

bash
sudo nano /etc/default/isc-dhcp-server
Contenu à ajouter :

bash
INTERFACESv4="eth0"

### 4. Configuration du serveur DHCP

bash
sudo nano /etc/dhcp/dhcpd.conf
Contenu à ajouter :

bash
# Configuration DHCP Server
authoritative;
default-lease-time 600;
max-lease-time 7200;

subnet 192.168.15.0 netmask 255.255.255.0 {
    range 192.168.15.100 192.168.15.200;
    option routers 192.168.15.254;
    option domain-name-servers 192.168.15.253;
    option domain-name "tutoserveurs.local";
}


## 🛠️ Gestion du Service

### 5. Démarrage du service

bash
sudo systemctl start isc-dhcp-server
sudo systemctl enable isc-dhcp-server

### 6. Vérification du statut

bash
systemctl status isc-dhcp-server

### 7. Redémarrage après modification

bash
sudo systemctl restart isc-dhcp-server

## 🔍 Dépannage

### 8. Vérifier les baux attribués

bash
tail /var/lib/dhcp/dhcpd.leases

### 9. Journal des logs en temps réel

bash
sudo journalctl -u isc-dhcp-server -f

### 10. Vérification syntaxique de la configuration

bash
sudo dhcpd -t

## 📊 Commandes Utiles

Vérification interface réseau

bash
ip addr show

Surveillance continue des baux

bash
tail -f /var/lib/dhcp/dhcpd.leases

Vérification détaillée des erreurs

bash

sudo journalctl -u isc-dhcp-server --no-pager

## ⚠️ Notes Importantes

Remplacez eth0 par le nom de votre interface réseau

Adaptez la plage IP 192.168.15.0/24 à votre réseau

Les modifications nécessitent un redémarrage du service

Vérifiez toujours la syntaxe avec dhcpd -t avant de redémarrer

## 🔧 Résolution de Problèmes Courants

Service ne démarre pas

bash
sudo journalctl -u isc-dhcp-server -n 50
Test de configuration

bash
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
Réinitialisation des baux

bash
sudo rm /var/lib/dhcp/dhcpd.leases*
sudo touch /var/lib/dhcp/dhcpd.leases
sudo systemctl restart isc-dhcp-server
