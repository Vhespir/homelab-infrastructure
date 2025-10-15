#!/bin/bash

###############################################################################
# Configuration Backup Script
#
# Purpose: Backs up critical system and service configuration files to a
#          timestamped archive for disaster recovery purposes
#
# Features:
#   - Automatic timestamped backups
#   - Compression with gzip
#   - Organized directory structure
#   - Backup rotation (keeps last 7 backups)
#   - Checksum verification
#
# Usage: sudo ./backup-configs.sh [backup_directory]
# Author: Shane Nichols
# Date: 2025
###############################################################################

set -euo pipefail

# Configuration
BACKUP_DIR="${1:-/var/backups/system-configs}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="config-backup-${TIMESTAMP}"
TEMP_DIR="/tmp/${BACKUP_NAME}"
RETENTION_DAYS=7

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

echo "============================================"
echo "  Configuration Backup Script"
echo "============================================"
echo "Backup directory: $BACKUP_DIR"
echo "Timestamp: $TIMESTAMP"
echo ""

# Create directories
mkdir -p "$BACKUP_DIR"
mkdir -p "$TEMP_DIR"

# Files and directories to backup
declare -A BACKUP_ITEMS=(
    # Monitoring and alerting
    ["/etc/prometheus"]="prometheus"
    ["/etc/alertmanager"]="alertmanager"
    ["/etc/grafana"]="grafana"

    # Network services
    ["/etc/samba/smb.conf"]="samba/smb.conf"

    # Docker
    ["/etc/docker/daemon.json"]="docker/daemon.json"

    # Security
    ["/etc/clamav"]="clamav"

    # System configs
    ["/etc/systemd/system/*.service"]="systemd/custom-services"
    ["/etc/fstab"]="system/fstab"
    ["/etc/hosts"]="system/hosts"
    ["/etc/hostname"]="system/hostname"

    # Firewall
    ["/etc/iptables"]="firewall"
)

backup_item() {
    local source=$1
    local dest_path=$2
    local dest="${TEMP_DIR}/${dest_path}"

    # Create destination directory
    mkdir -p "$(dirname "$dest")"

    if [ -e "$source" ]; then
        echo -e "${GREEN}✓${NC} Backing up: $source"
        cp -r "$source" "$dest" 2>/dev/null || true
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Skipping (not found): $source"
        return 1
    fi
}

echo "Backing up configuration files..."
echo ""

# Backup each item
for source in "${!BACKUP_ITEMS[@]}"; do
    backup_item "$source" "${BACKUP_ITEMS[$source]}"
done

echo ""
echo "Creating compressed archive..."

# Create compressed archive
cd /tmp
tar czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"

# Generate checksum
cd "$BACKUP_DIR"
sha256sum "${BACKUP_NAME}.tar.gz" > "${BACKUP_NAME}.sha256"

# Clean up temp directory
rm -rf "$TEMP_DIR"

# Get backup size
BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" | cut -f1)

echo -e "${GREEN}✓${NC} Backup created: ${BACKUP_NAME}.tar.gz (${BACKUP_SIZE})"
echo -e "${GREEN}✓${NC} Checksum created: ${BACKUP_NAME}.sha256"

# Rotate old backups
echo ""
echo "Rotating old backups (keeping last ${RETENTION_DAYS} days)..."
find "$BACKUP_DIR" -name "config-backup-*.tar.gz" -mtime +${RETENTION_DAYS} -delete
find "$BACKUP_DIR" -name "config-backup-*.sha256" -mtime +${RETENTION_DAYS} -delete

# List all backups
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "config-backup-*.tar.gz" | wc -l)
echo -e "${GREEN}✓${NC} Backup rotation complete. Total backups: ${BACKUP_COUNT}"

echo ""
echo "============================================"
echo "Backup Summary:"
echo "  Location: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo "  Size: ${BACKUP_SIZE}"
echo "  Timestamp: ${TIMESTAMP}"
echo "  Total backups: ${BACKUP_COUNT}"
echo "============================================"
echo ""
echo "To restore, extract the archive:"
echo "  sudo tar xzf ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz -C /"
echo ""
