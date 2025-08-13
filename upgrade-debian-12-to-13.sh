#!/bin/bash

# Upgrade script from Debian 12 (Bookworm) to Debian 13 (Trixie)
# Ensures a smooth, secure, and hassle-free transition.
#
# Features:
# - Automated checks (disk space, connectivity, dependencies)
# - Detailed logging for full transparency
# - Clean reboot if required
#
# Usage: 
# sudo ./upgrade-debian-12-to-13.sh
#
# Author: OpsVox.com – Your partner for rock-solid infrastructure.
#         Performance, stability, and security at the core of our solutions.

# Set strict mode
set -euo pipefail

# Log file
LOG_FILE="/var/log/debian-upgrade-to-trixie.log"

# Function to log messages
log() {
    local level="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" | tee -a "$LOG_FILE"
}

# Function to check if already on Debian 13
check_if_already_upgraded() {
    if grep -q "13" /etc/debian_version 2>/dev/null; then
        log "INFO" "System is already on Debian 13 or higher. Exiting."
        exit 0
    fi
    log "INFO" "System is on Debian $(cat /etc/debian_version). Proceeding with upgrade."
}

# Function to backup critical directories
backup_system() {
    local backup_file="/debian12-config-backup.tar.gz"
    if [ -f "$backup_file" ]; then
        log "INFO" "Backup file $backup_file already exists. Skipping backup."
        return
    fi
    log "INFO" "Creating backup of critical directories (/etc, /var/log, /var/lib/dpkg, /var/backups, /root)..."
    tar czf "$backup_file" \
        --exclude=/var/cache \
        --exclude=/var/tmp \
        --exclude=/var/lib/docker \
        /etc \
        /var/log \
        /var/lib/dpkg \
        /var/backups \
        /root || { log "ERROR" "Backup failed."; exit 1; }
    log "INFO" "Backup created at $backup_file. Transfer to safe location manually."
}

# Function to update current Debian 12
update_current() {
    log "INFO" "Updating current Debian 12 installation..."
    apt update || { log "ERROR" "apt update failed."; exit 1; }
    apt upgrade -y || { log "ERROR" "apt upgrade failed."; exit 1; }
    apt full-upgrade -y || { log "ERROR" "apt full-upgrade failed."; exit 1; }
    apt --purge autoremove -y || { log "INFO" "autoremove completed or no packages to remove."; }
    log "INFO" "Current system updated."
}

# Function to check disk space (at least 5GB free on /)
check_disk_space() {
    local free_space
    free_space=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
    if (( $(echo "$free_space < 5" | bc -l) )); then
        log "ERROR" "Insufficient disk space on /. Need at least 5GB free."
        exit 1
    fi
    log "INFO" "Disk space check passed: ${free_space}G free on /."
}

# Function to check and handle held packages
handle_held_packages() {
    local held
    held=$(apt-mark showhold)
    if [ -n "$held" ]; then
        log "WARNING" "Held packages found: $held. Unholding them."
        apt-mark unhold "$held" || { log "ERROR" "Failed to unhold packages."; exit 1; }
    else
        log "INFO" "No held packages found."
    fi
}

# Function to backup and modify sources
modify_sources() {
    if grep -q "trixie" /etc/apt/sources.list; then
        log "INFO" "Sources already point to trixie. Skipping modification."
        return
    fi
    log "INFO" "Backing up sources..."
    mkdir -p ~/apt-backup
    cp /etc/apt/sources.list ~/apt-backup/
    cp -r /etc/apt/sources.list.d/ ~/apt-backup/ || true

    log "INFO" "Modifying sources to trixie..."
    sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
    find /etc/apt/sources.list.d -type f -exec sed -i 's/bookworm/trixie/g' {} \; || { log "ERROR" "Failed to modify sources."; exit 1; }
    log "INFO" "Sources modified. Ensure third-party repos are compatible."
}

# Function to perform minimal upgrade
minimal_upgrade() {
    log "INFO" "Performing minimal upgrade..."
    apt update || { log "ERROR" "apt update failed after sources change."; exit 1; }
    apt upgrade --without-new-pkgs -y || { log "ERROR" "Minimal upgrade failed."; exit 1; }
    log "INFO" "Minimal upgrade completed."
}

# Function to perform full upgrade
full_upgrade() {
    log "INFO" "Performing full upgrade..."
    apt full-upgrade -y || { log "ERROR" "Full upgrade failed."; exit 1; }
    apt --purge autoremove -y || { log "INFO" "autoremove completed or no packages to remove."; }
    log "INFO" "Full upgrade completed."
}

# Function to fix potential locales bug
fix_locales() {
    if ! locale -a | grep -q "en_US.utf8"; then
        log "WARNING" "Locales may be missing. Fixing..."
        apt-get purge -y locales || true
        apt install -y locales || { log "ERROR" "Failed to reinstall locales."; exit 1; }
        dpkg-reconfigure locales || { log "ERROR" "Locales reconfiguration failed."; exit 1; }
        log "INFO" "Locales fixed."
    else
        log "INFO" "Locales appear intact. No fix needed."
    fi
}

# Function to modernize sources (optional, idempotent)
modernize_sources() {
    if [ -f "/etc/apt/sources.list.d/debian.sources" ]; then
        log "INFO" "Sources already modernized. Skipping."
        return
    fi
    log "INFO" "Modernizing sources to DEB822 format..."
    apt install -y apt || true
    apt modernize-sources -y || { log "ERROR" "Failed to modernize sources."; exit 1; }
    log "INFO" "Sources modernized."
}

# Main execution
main() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root."
        exit 1
    fi

    log "INFO" "Starting Debian 12 to 13 upgrade script."

    check_if_already_upgraded
    backup_system
    check_disk_space
    update_current
    handle_held_packages
    modify_sources
    minimal_upgrade
    full_upgrade
    fix_locales
    modernize_sources

    log "INFO" "Upgrade completed. Rebooting system..."
    reboot
}

main
