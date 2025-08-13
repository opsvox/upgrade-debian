# Mise à jour de Debian 12 (Bookworm) vers Debian 13 (Trixie)

## Version en anglais
Une version en anglais de ce document est disponible : [README.md](README.md)

---

## Aperçu
Ce script Bash automatise la mise à jour d’un système Debian 12 (Bookworm) vers Debian 13 (Trixie). Il respecte les bonnes pratiques Bash, avec des fonctions modulaires, un journal des actions dans `/var/log/debian-upgrade-to-trixie.log`, et des vérifications d’idempotence pour éviter les opérations redondantes ou nuisibles (par exemple, sauter si la mise à jour est déjà effectuée, si une sauvegarde existe, ou si les sources sont modifiées). Pour des raisons de sécurité, sauvegardez toujours vos données critiques et testez dans un environnement non productif avant d’exécuter.

**Exécuter le script** :
```bash
chmod +x upgrade-debian-12-to-13.sh
sudo ./upgrade-debian-12-to-13.sh
```

---

## Exemple de journaux
Consultez un exemple de journaux de mise à jour : [debian-upgrade-to-trixie.log](debian-upgrade-to-trixie.log)

---

## Problèmes traités
Le script gère des problèmes spécifiques au-delà des étapes standard de mise à jour (par exemple, mise à jour des sources, exécution de `full-upgrade`), en s’appuyant sur les errata officiels, les guides de mise à jour et les rapports de la communauté :

- **Problème de locales** : Évite les erreurs liées aux fichiers de locales manquants en purgeant, réinstallant et reconfigurant le paquet `locales`.
- **/tmp en tmpfs** : Debian 13 utilise par défaut `/tmp` comme tmpfs en mémoire (jusqu’à 50 % de la RAM). Ceci est noté dans les journaux ; pour revenir en arrière après la mise à jour, utilisez `systemctl mask tmp.mount` et redémarrez.
- **Synchronisation de l’installateur netboot** : Les fichiers netboot peuvent être désynchronisés initialement (non applicable pour les mises à jour sur place). Pour les installations neuves, attendez `trixie-updates`.
- **Changement TLS d’OpenLDAP** : Passage de GnuTLS à OpenSSL, nécessitant des mises à jour manuelles de `/etc/ldap/ldap.conf` si LDAP est utilisé.
- **Dépôts tiers** : Rappelle de vérifier la compatibilité des dépôts non-Debian (par exemple, Docker, Google Chrome) pour éviter des échecs.
- **Paquets bloqués** : Débloque automatiquement les paquets retenus pour éviter les blocages de mise à jour.
- **Espace disque** : Vérifie qu’au moins 5 Go sont libres sur `/` pour éviter les échecs en cours de mise à jour.
- **Bookworm-Backports** : Recommande de supprimer manuellement les backports de `sources.list` avant la mise à jour.

---

## Avantages de Debian 13 (Trixie) par rapport à Debian 12 (Bookworm)
Améliorations clés, classées par impact sur la sécurité, les performances, le support matériel et l’ergonomie :

1. **Sécurité renforcée** : Protections contre les exploits basées sur le matériel (Intel CET pour amd64, PAC/BTI pour arm64) contre les attaques ROP/COP/JOP. `time_t` 64 bits résout les problèmes Y2038. Mise à jour des outils cryptographiques (OpenSSL 3.5, GnuPG 2.4.7) et paquets sécurisés.
2. **Noyau Linux 6.12 LTS** : Évolution majeure depuis 6.1, avec support pour Wi-Fi 7, MIDI 2.0, USB4 v2, PREEMPT_RT en temps réel, et optimisations pour les systèmes de fichiers (Btrfs, EXT4, Bcachefs). Support LTS jusqu’en 2026.
3. **Mises à jour massives des paquets** : Plus de 69 000 paquets (14 000 nouveaux, 63 % mis à jour), incluant GCC 14.2, Python 3.13, PHP 8.4, PostgreSQL 17, LibreOffice 25.2 et GIMP 3.0.4, pour un développement moderne et des corrections de bugs.
4. **Support RISC-V** : Support officiel de `riscv64` pour le matériel RISC-V 64 bits, abandon de l’architecture i386/32 bits pour se concentrer sur le matériel moderne.
5. **Environnements de bureau améliorés** : GNOME 48 (animations fluides, notifications améliorées), KDE Plasma 6.3 (basé sur Qt 6, meilleure mise à l’échelle), Xfce 4.20 (support Wayland) et LXQt 2.1.0, pour une meilleure ergonomie.
6. **Optimisations des performances** : `/tmp` en tmpfs par défaut pour des E/S plus rapides, constructions reproductibles pour la vérification, et support HTTP/3 dans `curl` pour le web moderne.
7. **Améliorations de l’installateur et du démarrage** : Support du démarrage HTTP pour UEFI/U-Boot, meilleure correction orthographique dans les navigateurs Qt WebEngine, et traductions améliorées des pages de manuel.

---

## Documentations officielles de Debian 13 [Trixie]

Quelques documentations qui ont permis de créer ce script :

- [https://www.debian.org/releases/trixie/amd64/](https://www.debian.org/releases/trixie/amd64/)
- [https://www.debian.org/releases/trixie/errata](https://www.debian.org/releases/trixie/errata)
- [https://wiki.debian.org/DebianUpgrade](https://wiki.debian.org/DebianUpgrade)

---

## Contact
Pour toute question ou suggestion, visitez : **[https://opsvox.com/fr/contact](https://opsvox.com/fr/contact)**.
