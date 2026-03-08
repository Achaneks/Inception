FROM debian:bookworm

# Install MariaDB server
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Create the directory MariaDB needs for its socket file
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

# Copy our init script
COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

EXPOSE 3306

# Run our init script which starts MariaDB
ENTRYPOINT ["/init_db.sh"]

