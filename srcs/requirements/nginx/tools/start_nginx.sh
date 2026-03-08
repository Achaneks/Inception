#!/bin/bash
set -e

echo "[NGINX] Waiting for WordPress to populate /var/www/html..."

# Wait until WordPress has written index.php to the shared volume
# This prevents NGINX from serving 403 before WordPress is ready
until [ -f /var/www/html/index.php ]; do
    echo "[NGINX] index.php not found yet, waiting 2s..."
    sleep 2
done

echo "[NGINX] WordPress files found! Starting NGINX..."
exec nginx -g "daemon off;"