FROM debian:bookworm

RUN apt update && apt install -y nginx openssl

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 \
-subj "/C=MA/ST=Casablanca/L=Casablanca/O=42/OU=student/CN=achanek.42.fr" \
-newkey rsa:2048 \
-keyout /etc/nginx/ssl/inception.key \
-out /etc/nginx/ssl/inception.crt

CMD ["nginx", "-g", "daemon off;"]