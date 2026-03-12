#!/bin/bash
set -e

DATA_DIR="/var/lib/mysql"
INIT_MARKER="$DATA_DIR/.inception_init_done"

if [ ! -f "$INIT_MARKER" ]; then
    chown -R mysql:mysql "$DATA_DIR" || true
    if command -v mysql_install_db >/dev/null 2>&1; then
        mysql_install_db --user=mysql --datadir="$DATA_DIR" > /dev/null
    else
        mysqld --initialize-insecure --user=mysql --datadir="$DATA_DIR" > /dev/null 2>&1 || true
    fi
    mysqld --user=mysql --datadir="$DATA_DIR" \
           --skip-networking \
           --socket=/tmp/mysql_setup.sock &
    MYSQL_PID=$!

    until mysqladmin --socket=/tmp/mysql_setup.sock ping --silent 2>/dev/null; do
        sleep 1
    done

    mysql --socket=/tmp/mysql_setup.sock -u root << EOF
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

    kill "$MYSQL_PID"
    wait "$MYSQL_PID" 2>/dev/null || true
    touch "$INIT_MARKER"
fi

exec mysqld --user=mysql \
            --datadir="$DATA_DIR" \
            --bind-address=0.0.0.0 \
            --skip-ssl