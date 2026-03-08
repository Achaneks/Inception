#!/bin/bash

sleep 10

cd /var/www/html

if [ ! -f wp-config.php ]; then

wp core download --allow-root

wp config create \
 --dbname=$MYSQL_DATABASE \
 --dbuser=$MYSQL_USER \
 --dbpass=$MYSQL_PASSWORD \
 --dbhost=mariadb \
 --allow-root

wp core install \
 --url=$DOMAIN_NAME \
 --title="Inception" \
 --admin_user=$WP_ADMIN \
 --admin_password=$WP_ADMIN_PASSWORD \
 --admin_email=$WP_ADMIN_EMAIL \
 --skip-email \
 --allow-root

wp user create \
 $WP_USER \
 $WP_USER_EMAIL \
 --user_pass=$WP_USER_PASSWORD \
 --role=author \
 --allow-root

fi

php-fpm8.2 -F