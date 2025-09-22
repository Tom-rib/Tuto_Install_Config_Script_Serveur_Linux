# README général du projet Tuto Serveurs

Ce projet fournit un mémo complet pour installer, configurer et tester les principaux services Linux. Les services sont organisés par catégories et chaque service possède ses sous-dossiers `client` et `serveur` sur debian 12.

# Comptes génériques pour le projet Tuto Serveurs

## 1️⃣ Utilisateurs Linux

| Rôle     | Nom d'utilisateur | Mot de passe   |
|----------|-------------------|----------------|
| Serveur1 | serveur1          | TutoPass123!   |
| Client1  | client1           | TutoPass123!   |
| Client2  | client2           | TutoPass123!   |

## 2️⃣ Comptes administrateurs des applications

| Application                          | Nom d'utilisateur | Mot de passe      |
|--------------------------------------|-------------------|-------------------|
| MySQL / MariaDB / LDAP / autres      | admin             | AdminPass123!     |


## Sommaire avec liens vers chaque service

### Réseau et communication

* [DHCP](./services/Reseau-et-communication/DHCP) – Attribution automatique d’adresses IP, installation, configuration serveur/client, tests et scripts.
* [DNS (Bind9)](./services/Reseau-et-communication/DNS_Bind9/README.md) – Résolution de noms, installation, configuration serveur/client, tests et scripts.
* [VPN (OpenVPN / WireGuard)](./services/Reseau-et-communication/VPN_OpenVPN-WireGuard/README.md) – Réseau privé sécurisé, installation, configuration serveur/client, tests et scripts.
* [SSH](./services/Reseau-et-communication/SSH/README.md) – Connexion sécurisée, installation, configuration, tests et scripts.
* [FTP / SFTP](./services/Reseau-et-communication/FTP-SFTP/README.md) – Transfert de fichiers, installation, configuration, tests et scripts.
* [Bastion / Guacamole](./services/Reseau-et-communication/Bastion-Guacamole/README.md) – Accès centralisé et sécurisé aux machines, installation, configuration, tests et scripts.

### Stockage

* [Samba](./services/Stockage/Samba/README.md) – Partage fichiers Windows/Linux, installation, configuration, tests et scripts.
* [NFS](./services/Stockage/NFS/README.md) – Partage fichiers Linux, installation, configuration, tests et scripts.
* [RAID (mdadm)](./services/Stockage/RAID_mdadm/README.md) – Redondance et performance disque, installation, configuration, tests et scripts.
* [TrueNAS / NAS](./services/Stockage/TrueNAS-NAS/README.md) – Gestion centralisée du stockage, installation, configuration, tests et scripts.

### Web et applicatif

* [Serveur Web Apache](./services/Web-et-applicatif/Web_Apache/README.md) – Hébergement de sites web, installation, configuration, tests et scripts.
* [Serveur Web Nginx](./services/Web-et-applicatif/Web_Nginx/README.md) – Hébergement de sites web, installation, configuration, tests et scripts.
* [Reverse Proxy (Nginx / HAProxy)](./services/Web-et-applicatif/ReverseProxy_Nginx-HAProxy/README.md) – Distribution de trafic web, installation, configuration, tests et scripts.
* [Base de données MySQL (Oracle)](./services/Web-et-applicatif/BDD_MySQL_Oracle/README.md) – Stockage structuré, installation, configuration, tests et scripts.
* [Base de données MariaDB](./services/Web-et-applicatif/BDD_MySQL_MariaDB/README.md) – Stockage structuré, installation, configuration, tests et scripts.
* [LDAP (OpenLDAP / FreeIPA)](./services/Web-et-applicatif/LDAP_OpenLDAP-FreeIPA/README.md) – Gestion centralisée des utilisateurs, installation, configuration, tests et scripts.

### Communication

* [VOIP / Asterisk](./services/Communication/VOIP_Asterisk/README.md) – Téléphonie IP, installation, configuration, tests et scripts.
* [Messagerie / Mail (Postfix / Dovecot)](./services/Communication/Mail_Postfix-Dovecot/README.md) – Serveur mail, installation, configuration, tests et scripts.

### Supervision et sécurité

* [Firewall (nftables / iptables)](./services/Supervision-et-securite/Firewall_nftables-iptables/README.md) – Sécurisation du réseau, installation, configuration, tests et scripts.
* [Fail2Ban](./services/Supervision-et-securite/Fail2Ban/README.md) – Protection contre les intrusions, installation, configuration, tests et scripts.
* [Supervision (Nagios / Zabbix / Prometheus)](./services/Supervision-et-securite/Supervision_Nagios-Zabbix-Prometheus/README.md) – Supervision réseau et services, installation, configuration, tests et scripts.

---

## Structure de chaque dossier service `services/<CATEGORY>/<SERVICE>/`

* `README.md` : installation manuelle, configuration serveur/client, procédure de test et utilisation des scripts.
* `install_interactive.sh` : script interactif pour installer et configurer le service.
* `deploy_auto.sh` : script automatique pour installation rapide.
* `tests/` : scripts et commandes pour tester le service côté serveur et client.
* `common_issues.md` : problèmes fréquents et solutions.
* `examples/` : fichiers de configuration et modèles prêts à copier et adapter.


---

# Exemple de structure du dossier DHCP

Le dossier `DHCP` est organisé en deux sous-dossiers : `client` et `serveur`, chacun contenant la procédure d'installation manuelle, les commandes de test et les scripts d'automatisation.

## Dossier DHCP

### 1. Client

* **Installation manuelle** : étapes pour installer le client DHCP (ex: `apt install isc-dhcp-client`)
* **Commandes de test** : commandes pour vérifier que le client reçoit bien une adresse IP (`dhclient -v <iface>`, `ip addr show <iface>`)
* **Script d'automatisation** : `install_client.sh` pour automatiser la configuration et l'obtention d'une IP via DHCP

### 2. Serveur

* **Installation manuelle** : étapes pour installer le serveur DHCP (ex: `apt install isc-dhcp-server`)
* **Commandes de test** : vérifier le service et les baux distribués (`systemctl status isc-dhcp-server`, `tail /var/lib/dhcp/dhcpd.leases`)
* **Script d'automatisation** : `install_server.sh` pour configurer le serveur DHCP avec interface, pool, gateway et DNS automatiquement

## Structure des fichiers

```
DHCP/
├── client/
│   ├── README.md (procédure client, tests, script)
│   ├── install_client.sh
│   └── tests_client.sh
└── serveur/
    ├── README.md (procédure serveur, tests, script)
    ├── install_server.sh
    └── tests_server.sh
```

Chaque README détaille les étapes d'installation manuelle, la configuration, les tests et comment utiliser le script d'automatisation.
