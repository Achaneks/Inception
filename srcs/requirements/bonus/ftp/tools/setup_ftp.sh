#!/bin/bash
set -e

# Create FTP user if it doesn't exist
if ! id "${FTP_USER}" &>/dev/null; then
    echo "[FTP] Creating user ${FTP_USER}..."
    useradd -m -d /var/www/html "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
fi

# Make sure FTP user owns the WordPress directory
chown -R "${FTP_USER}:${FTP_USER}" /var/www/html

echo "[FTP] Starting vsftpd..."
exec vsftpd /etc/vsftpd.conf