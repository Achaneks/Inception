FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

COPY html/ /var/www/static/

RUN echo 'server { \
    listen 8080; \
    root /var/www/static; \
    index index.html; \
    location / { try_files $uri $uri/ =404; } \
}' > /etc/nginx/sites-available/default

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]