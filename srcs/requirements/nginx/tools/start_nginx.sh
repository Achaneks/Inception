#!/bin/bash
set -e
until [ -f /var/www/html/index.php ]; do
    echo "[NGINX] index.php not found yet, waiting 2s..."
    sleep 2
done
exec nginx -g "daemon off;"