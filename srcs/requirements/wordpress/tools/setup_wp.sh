#!/bin/bash
set -e

WP_DIR="/var/www/html"
WP_SRC="/usr/src/wordpress"

# ── Step 1: Copy WordPress files from staging to volume ──────
if [ ! -f "$WP_DIR/wp-login.php" ]; then
    echo "[WordPress] Copying WordPress core files to volume..."
    cp -r "$WP_SRC/." "$WP_DIR/"
fi

# ── Step 2: Wait for MariaDB ─────────────────────────────────
until mysql -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1;" > /dev/null 2>&1; do
    sleep 3
done
echo "[WordPress] MariaDB is ready!"

if [ ! -f "$WP_DIR/wp-config.php" ]; then

    echo "[WordPress] Creating wp-config.php..."
    wp config create \
        --path="$WP_DIR" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    echo "[WordPress] Installing WordPress..."
    wp core install \
        --path="$WP_DIR" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "[WordPress] Creating editor user..."
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=editor \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="$WP_DIR" \
        --allow-root

    echo "[WordPress] Installing Redis cache plugin..."
    wp plugin install redis-cache --activate \
        --path="$WP_DIR" --allow-root

    echo "[WordPress] Configuring Redis connection..."
    wp config set WP_REDIS_HOST redis \
        --path="$WP_DIR" --allow-root
    wp config set WP_REDIS_PORT 6379 \
        --path="$WP_DIR" --allow-root

    echo "[WordPress] Setup complete!"
fi

echo "[WordPress] Enabling Redis object cache..."
wp redis enable --path="$WP_DIR" --allow-root 2>/dev/null || true

chown -R www-data:www-data "$WP_DIR"
find "$WP_DIR" -type d -exec chmod 755 {} \;
find "$WP_DIR" -type f -exec chmod 644 {} \;

# ── Step 6: Switch PHP-FPM to TCP port 9000 ─────────────────
sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' \
    /etc/php/8.2/fpm/pool.d/www.conf

echo "[WordPress] Starting PHP-FPM on port 9000..."
exec php-fpm8.2 --nodaemonize