#!/bin/bash
set -e
until [ -f /var/www/html/index.php ]; do
    sleep 2
done
exec nginx -g "daemon off;"