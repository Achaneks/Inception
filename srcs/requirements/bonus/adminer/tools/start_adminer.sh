#!/bin/bash
set -e

# Switch PHP-FPM to listen on TCP port 9001 (9000 is used by WordPress)
sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9001|' \
    /etc/php/8.2/fpm/pool.d/www.conf

echo "[Adminer] Starting PHP-FPM on port 9001..."
exec php-fpm8.2 --nodaemonize