#!/bin/bash

# Wait for wordpress volume to be populated
while [ ! -f /var/www/html/wp-config.php ]; do
    sleep 2
done

# Create www-data group if not exists
groupadd -f -g 33 www-data 2>/dev/null || true

# Create FTP user and add to www-data group
if ! id -u "$FTP_USER" > /dev/null 2>&1; then
    useradd -m -g www-data -d /var/www/html "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
fi

mkdir -p /var/run/vsftpd/empty

# Ensure FTP user has write permissions
chown -R www-data:www-data /var/www/html
chmod -R g+w /var/www/html

exec /usr/sbin/vsftpd /etc/vsftpd.conf
