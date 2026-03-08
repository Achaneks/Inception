FROM debian:bookworm

RUN apt update && apt upgrade -y && \
    apt install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY tools/init_db.sh /init_db.sh
RUN chmod +x /init_db.sh

EXPOSE 3306

CMD ["/init_db.sh"]