#!/bin/bash
set -e

# Wait until WordPress has populated the volume
echo "[FTP] Waiting for WordPress files..."
until [ -f /var/www/html/wp-login.php ]; do
    sleep 2
done
echo "[FTP] WordPress files found!"

# Create FTP user only if it doesn't exist
if ! id "${FTP_USER}" &>/dev/null; then
    echo "[FTP] Creating user ${FTP_USER}..."
    # Home = /var/www/html, no separate home folder
    useradd -d /var/www/html -M -s /bin/bash "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
fi

# Add FTP user to www-data group so it can write to www-data owned files
usermod -aG www-data "${FTP_USER}"

# Set group write permissions on the WordPress directory
# www-data owns it (WordPress needs this), but group members can also write
chmod -R g+w /var/www/html
find /var/www/html -type d -exec chmod g+s {} \;

echo "[FTP] Starting vsftpd..."
exec vsftpd /etc/vsftpd.conf