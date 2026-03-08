FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-zip \
    wget \
    curl \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Download WordPress into a STAGING directory (not /var/www/html)
# At runtime, the setup script copies from here into the volume
RUN wp core download --path=/usr/src/wordpress --allow-root

# Make sure PHP-FPM run dir exists
RUN mkdir -p /run/php

COPY tools/setup_wp.sh /setup_wp.sh
RUN chmod +x /setup_wp.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/setup_wp.sh"]