#!/bin/bash
set -e

WP_DIR="/var/www/html"
WP_SRC="/usr/src/wordpress"

if [ ! -f "$WP_DIR/wp-login.php" ]; then
    cp -r "$WP_SRC/." "$WP_DIR/"
fi

until mysql -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "SELECT 1;" > /dev/null 2>&1; do
    sleep 3
done



if [ ! -f "$WP_DIR/wp-config.php" ]; then

    wp config create \
        --path="$WP_DIR" \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    wp core install \
        --path="$WP_DIR" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=editor \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="$WP_DIR" \
        --allow-root
fi

chown -R www-data:www-data "$WP_DIR"
find "$WP_DIR" -type d -exec chmod 755 {} \;
find "$WP_DIR" -type f -exec chmod 644 {} \;

sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' \
    /etc/php/8.2/fpm/pool.d/www.conf

exec php-fpm8.2 --nodaemonize