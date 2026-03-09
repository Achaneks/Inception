#!/bin/bash
set -e

DATA_DIR="/var/lib/mysql"
INIT_MARKER="$DATA_DIR/.inception_init_done"

# ── First run only: initialize DB and create WordPress user ──
if [ ! -f "$INIT_MARKER" ]; then

    echo "[MariaDB] Initializing data directory..."
    # Ensure ownership and initialize data directory. Prefer mysql_install_db
    # when available; otherwise fall back to mysqld --initialize-insecure.
    chown -R mysql:mysql "$DATA_DIR" || true
    if command -v mysql_install_db >/dev/null 2>&1; then
        mysql_install_db --user=mysql --datadir="$DATA_DIR" > /dev/null
    else
        echo "[MariaDB] mysql_install_db not found, running mysqld --initialize-insecure"
        mysqld --initialize-insecure --user=mysql --datadir="$DATA_DIR" > /dev/null 2>&1 || true
    fi

    echo "[MariaDB] Starting temporary server for setup..."
    mysqld --user=mysql --datadir="$DATA_DIR" \
           --skip-networking \
           --socket=/tmp/mysql_setup.sock &
    MYSQL_PID=$!

    # Wait until the socket is ready
    echo "[MariaDB] Waiting for temp server..."
    until mysqladmin --socket=/tmp/mysql_setup.sock ping --silent 2>/dev/null; do
        sleep 1
    done

    echo "[MariaDB] Running setup SQL..."

    mysql --socket=/tmp/mysql_setup.sock -u root << EOF
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

    echo "[MariaDB] Setup done. Shutting down temp server..."
    kill "$MYSQL_PID"
    wait "$MYSQL_PID" 2>/dev/null || true
    echo "[MariaDB] Temp server stopped."
    touch "$INIT_MARKER"
fi

echo "[MariaDB] Starting MariaDB in foreground on port 3306..."
exec mysqld --user=mysql \
            --datadir="$DATA_DIR" \
            --bind-address=0.0.0.0 \
            --skip-ssl