FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download Adminer — a single PHP file database manager
RUN mkdir -p /var/www/adminer && \
    wget -q https://www.adminer.org/latest.php -O /var/www/adminer/index.php

RUN mkdir -p /run/php

COPY tools/start_adminer.sh /start_adminer.sh
RUN chmod +x /start_adminer.sh

EXPOSE 9001

ENTRYPOINT ["/start_adminer.sh"]