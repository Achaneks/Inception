FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2 \
    php8.2-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer && \
    wget -q https://www.adminer.org/latest.php -O /var/www/adminer/index.php

EXPOSE 9001

WORKDIR /var/www/adminer

CMD ["php", "-S", "0.0.0.0:9001"] 