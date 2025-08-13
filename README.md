# Upgrade Debian 12 (Bookworm) to Debian 13 (Trixie)

## French Version
A French version of this document is available: [README-fr.md](README-fr.md)

---

## Overview
This Bash script automates the upgrade of a Debian 12 (Bookworm) system to Debian 13 (Trixie). It follows Bash best practices, using modular functions, logging all actions to `/var/log/debian-upgrade-to-trixie.log`, and implementing idempotence checks to prevent redundant or harmful operations (e.g., skipping if already upgraded, if backups exist, or if sources are modified). For safety, always back up critical data and test in a non-production environment before running.

**Run the script**:
```bash
chmod +x upgrade-debian-12-to-13.sh
sudo ./upgrade-debian-12-to-13.sh
```

---

## Sample Logs
View an example of the upgrade logs: [debian-upgrade-to-trixie.log](debian-upgrade-to-trixie.log)

---

## Handled Issues
The script addresses common issues beyond standard upgrade steps (e.g., updating sources, running `full-upgrade`), based on official errata, upgrade guides, and community reports:

- **Locales Bug**: Prevents errors from missing locale files by purging, reinstalling, and reconfiguring the `locales` package.
- **/tmp as tmpfs**: Debian 13 defaults `/tmp` to an in-memory tmpfs (up to 50% RAM). This is noted in logs; revert post-upgrade if needed with `systemctl mask tmp.mount` and reboot.
- **Netboot Installer Sync**: Netboot files may be out of sync initially (not applicable for in-place upgrades). For fresh installs, wait for `trixie-updates`.
- **OpenLDAP TLS Change**: Switches to OpenSSL from GnuTLS, requiring manual updates to `/etc/ldap/ldap.conf` if using LDAP.
- **Third-Party Repositories**: Logs reminders to verify compatibility of non-Debian repos (e.g., Docker, Google Chrome) to prevent upgrade failures.
- **Held Packages**: Automatically unholds packages to avoid upgrade blocks.
- **Disk Space**: Ensures at least 5GB free on `/` to prevent mid-upgrade failures.
- **Bookworm-Backports**: Recommends manually removing backports from `sources.list` before upgrading.

---

## Benefits of Debian 13 (Trixie) Over Debian 12 (Bookworm)
Key improvements, ordered by impact on security, performance, hardware support, and usability:

1. **Enhanced Security**: Hardware-based exploit protections (Intel CET for amd64, PAC/BTI for arm64) mitigate ROP/COP/JOP attacks. 64-bit `time_t` resolves Y2038 issues. Updated crypto (OpenSSL 3.5, GnuPG 2.4.7) and hardened packages reduce vulnerabilities.
2. **Linux Kernel 6.12 LTS**: Upgraded from 6.1, with support for Wi-Fi 7, MIDI 2.0, USB4 v2, real-time PREEMPT_RT, and optimized filesystems (Btrfs, EXT4, Bcachefs). LTS support until 2026 ensures stability.
3. **Extensive Package Updates**: Over 69,000 packages (14,000 new, 63% updated), including GCC 14.2, Python 3.13, PHP 8.4, PostgreSQL 17, LibreOffice 25.2, and GIMP 3.0.4, enabling modern development and bug fixes.
4. **RISC-V Support**: Official `riscv64` support for 64-bit RISC-V hardware, with i386/32-bit x86 dropped for modern hardware focus.
5. **Improved Desktop Environments**: GNOME 48 (smoother animations, better notifications), KDE Plasma 6.3 (Qt 6-based, enhanced scaling), Xfce 4.20 (Wayland support), and LXQt 2.1.0 improve usability and performance.
6. **Performance Enhancements**: Default `/tmp` as tmpfs for faster I/O, reproducible builds for verification, and HTTP/3 support in `curl` for modern web performance.
7. **Installer and Boot Improvements**: HTTP Boot support for UEFI/U-Boot, enhanced spell-checking in Qt WebEngine browsers, and improved man-page translations.

---

## Debian 13 [Trixie] Official Documentation
Some documentation used to create this script:

- [https://www.debian.org/releases/trixie/amd64/](https://www.debian.org/releases/trixie/amd64/)
- [https://www.debian.org/releases/trixie/errata](https://www.debian.org/releases/trixie/errata)
- [https://wiki.debian.org/DebianUpgrade](https://wiki.debian.org/DebianUpgrade)

---

## Contact
For questions or suggestions, visit : **[https://opsvox.com/contact](https://opsvox.com/contact)**.
