#!/bin/bash

# Start MariaDB temporarily
service mariadb start

# Wait for server to start
sleep 5

# Read passwords from secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Create database and users
mariadb -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Stop temporary server
mysqladmin -u root -p${DB_ROOT_PASSWORD} shutdown

# Start MariaDB in foreground
exec mysqld_safe