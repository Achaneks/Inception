FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy nginx config and startup script
COPY conf/nginx.conf /etc/nginx/sites-available/default
COPY tools/start_nginx.sh /start_nginx.sh
RUN chmod +x /start_nginx.sh

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/C=MA/ST=Khouribga/L=Khouribga/O=1337/CN=achanek.42.fr"

EXPOSE 443

ENTRYPOINT ["/start_nginx.sh"]