# Guide complet pour installer et configurer un client DNS (Bind9) sur Linux

## 📋 Table des matières

- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
  - [Méthode temporaire](#méthode-temporaire-test-rapide)
  - [Méthode persistante](#méthode-persistante)
- [Tests et vérifications](#tests-et-vérifications)
- [Commandes utiles](#commandes-utiles)
- [Notes importantes](#notes-importantes)

---

## ✅ Prérequis

- Système Linux (Debian/Ubuntu)
- Accès superutilisateur (sudo)
- Interface réseau fonctionnelle
- Adresse IP du serveur DNS disponible (`192.168.136.253`)

---

## 📥 Installation

### 1. Mise à jour des paquets

```bash
sudo apt update
```

### 2. Installation des utilitaires DNS

```bash
sudo apt install -y bind9-dnsutils
```

> **📌 Information :** `bind9-dnsutils` inclut `dig`, `nslookup` et autres outils pour tester la résolution DNS.

---

## ⚙️ Configuration

### Configuration du client pour utiliser le serveur DNS

### Méthode temporaire (test rapide)

```bash
sudo nano /etc/resolv.conf
```

**Ajoutez/modifiez :**

```bash
nameserver 192.168.136.253   # Remplacer par l'IP de votre serveur DNS
search tutoserveurs.local     # Remplacer par votre domaine
```

### Méthode persistante

#### Via DHCP

Si l'interface est configurée via DHCP, assurez-vous que le serveur DHCP distribue l'IP du serveur DNS :

```bash
option domain-name-servers 192.168.136.253;
```

#### Configuration statique

Pour une interface statique, ajoutez l'IP du DNS dans `/etc/network/interfaces` (Debian classique) :

```bash
auto eth0
iface eth0 inet static
    address 192.168.136.10
    netmask 255.255.255.0
    gateway 192.168.136.254
    dns-nameservers 192.168.136.253
    dns-search tutoserveurs.local
```

**Puis redémarrez le réseau :**

```bash
sudo systemctl restart networking
```

---

## 🧪 Tests et vérifications

### 4. Vérification du serveur DNS utilisé

```bash
cat /etc/resolv.conf
```

> **✅ Vérifiez** que `nameserver` correspond à votre serveur DNS (`192.168.136.253`).

### 5. Test de résolution directe

```bash
dig @192.168.136.253 serveur1.tutoserveurs.local
```

> **📋 Résultat attendu :** Vous devriez obtenir l'adresse IP correspondante.

### 6. Test de résolution inverse

```bash
dig @192.168.136.253 -x 192.168.136.254
```

> **📋 Résultat attendu :** Vérifiez que le nom du serveur ou client est bien résolu.

### 7. Test d'un nom de domaine externe

```bash
dig @192.168.136.253 www.google.com
```

> **📋 Résultat attendu :** Si Bind9 est configuré en forwarder, il devrait résoudre les noms externes.

---

## 🔧 Commandes utiles

| Commande | Description |
|----------|-------------|
| `dig @DNS_IP NOM` | Test de résolution directe pour un nom |
| `dig @DNS_IP -x IP` | Test de résolution inverse pour une IP |
| `nslookup NOM DNS_IP` | Alternative pour tester la résolution |
| `systemctl status named` | Vérifie que le service Bind9 est actif (serveur) |
| `cat /etc/resolv.conf` | Affiche les DNS utilisés par le client |

### Exemples pratiques

```bash
# Test de résolution avec le serveur DNS spécifique
dig @192.168.136.253 client1.tutoserveurs.local

# Test de résolution inverse
dig @192.168.136.253 -x 192.168.136.10

# Vérification du statut réseau
ip addr show
```

---

## 💡 Notes importantes

> **⚠️ Points importants à retenir :**

- **Interface réseau** : Remplacez `eth0` par le nom de votre interface réseau si nécessaire
- **Configuration DHCP** : La configuration via DHCP est recommandée pour éviter les conflits DNS
- **Tests explicites** : Utilisez `dig` avec `@DNS_IP` pour tester explicitement votre serveur DNS et non le DNS par défaut du système
- **Multi-interface** : Pour les clients multi-IP ou multi-interface, répétez la configuration DNS sur chaque interface

### 🔍 Diagnostic en cas de problème

```bash
# Vérifier la connectivité réseau
ping 192.168.136.253

# Vérifier les routes
ip route show

# Consulter les logs système
sudo journalctl -u systemd-resolved
```

---

### 🔗 Liens de navigation rapide

- [↑ Retour au sommaire](#-table-des-matières)
- [→ Prérequis](#prérequis)
- [→ Installation](#installation)
- [→ Configuration](#configuration)
- [→ Tests](#tests-et-vérifications)