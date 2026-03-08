FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    curl \
    mariadb-client \
    unzip \
    && apt-get clean

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

CMD ["/setup.sh"]