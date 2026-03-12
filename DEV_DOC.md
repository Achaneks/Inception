# DEV_DOC — Developer Documentation

## Prerequisites

Before setting up the project, ensure the following are installed on your Virtual Machine:

```bash
# Docker Engine
curl -fsSL https://get.docker.com | sh

# Verify Docker
docker --version
docker compose version

# make
sudo apt install make -y

# Verify
make --version
```

---

## Environment Setup From Scratch

### 1. Clone the repository

```bash
git clone <repo_url>
cd inception
```

### 2. Replace the login

Replace `achanek` with your actual 42 login in these files:

| File | What to change |
|---|---|
| `Makefile` | `LOGIN = achanek` |
| `srcs/docker-compose.yml` | volume `device:` paths |
| `srcs/requirements/nginx/conf/nginx.conf` | `server_name` |
| `srcs/requirements/nginx/Dockerfile` | SSL cert `-subj CN=` field |
| `srcs/.env` | `DOMAIN_NAME` and email fields |

### 3. Configure credentials

```bash
vim srcs/.env
```

Fill in all values. Rules:
- `WP_ADMIN_USER` must **not** contain the word `admin`
- All passwords should be strong (mixed chars, 12+ length)
- Do not commit this file — it is in `.gitignore`

### 4. Add domain to hosts file

```bash
echo "127.0.0.1 achanek.42.fr" | sudo tee -a /etc/hosts
```

### 5. Build and start

```bash
make
```

This automatically:
- Creates `/home/achanek/data/wordpress` and `/home/achanek/data/mariadb` on the host
- Builds all Docker images from Dockerfiles
- Starts all containers in detached mode

---

## Project Structure

```
inception/
├── Makefile                          ← build and lifecycle commands
├── README.md                         ← project overview (required)
├── USER_DOC.md                       ← user documentation (required)
├── DEV_DOC.md                        ← developer documentation (required)
├── .gitignore                        ← excludes .env and data/
└── srcs/
    ├── .env                          ← credentials (never commit this)
    ├── docker-compose.yml            ← defines all services, networks, volumes
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile            ← installs nginx + openssl, generates SSL cert
        │   ├── conf/nginx.conf       ← HTTPS, TLS 1.2/1.3, FastCGI, bonus routes
        │   └── tools/start_nginx.sh  ← waits for WordPress then starts nginx
        ├── mariadb/
        │   ├── Dockerfile            ← installs mariadb-server
        │   └── tools/init_db.sh     ← initializes DB and creates WordPress user
        ├── wordpress/
        │   ├── Dockerfile            ← installs PHP 8.2 + extensions + WP-CLI, downloads WP
        │   └── tools/setup_wp.sh    ← waits for MariaDB, installs WP, enables Redis, starts PHP-FPM
        └── bonus/
            ├── redis/
            │   ├── Dockerfile
            │   └── conf/redis.conf  ← protected-mode disabled for Docker network
            ├── ftp/
            │   ├── Dockerfile
            │   ├── conf/vsftpd.conf
            │   └── tools/setup_ftp.sh
            ├── adminer/
            │   ├── Dockerfile
            │   └── tools/start_adminer.sh
            ├── website/
            │   ├── Dockerfile
            │   └── html/index.html
            └── grafana/
                ├── Dockerfile
                ├── conf/grafana.ini
                └── tools/setup_grafana.sh
```

---

## Makefile Commands

| Command | Description |
|---|---|
| `make` | Create data dirs + build images + start containers |
| `make down` | Stop and remove containers (data preserved) |
| `make re` | `make down` + `make` — full restart |
| `make clean` | Stop containers + remove all Docker images and cache |
| `make fclean` | Full clean: images + volumes + host data directories |
| `make status` | Show running container status |
| `make logs` | Follow live logs from all containers |

---

## Docker Compose and Container Management

```bash
# Build and start with visible logs (no -d)
docker compose -f srcs/docker-compose.yml up --build

# List all running containers
docker ps

# Enter a container shell for debugging
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
docker exec -it redis bash

# Follow logs of one service
docker logs -f wordpress
docker logs -f mariadb

# Restart a single container without rebuilding
docker compose -f srcs/docker-compose.yml restart wordpress
```

---

## Data Storage and Persistence

All persistent data lives on the host machine:

```
/home/achanek/data/
├── wordpress/    ← WordPress files: wp-config.php, themes, plugins, uploads
└── mariadb/      ← MariaDB data files: ibdata1, wordpress/ table files
```

These are mounted into containers using Docker named volumes with `driver_opts`:

```yaml
volumes:
  wordpress:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/achanek/data/wordpress
```

**Verify volumes:**
```bash
docker volume ls
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb
```

**Verify data on host:**
```bash
ls /home/achanek/data/wordpress/   # WordPress files
ls /home/achanek/data/mariadb/     # MariaDB binary files
```

**Test persistence:**
1. Create a post at `https://achanek.42.fr/wp-admin`
2. Run `make down && make`
3. The post must still exist
4. Run `sudo reboot`, then `make` after reboot
5. Everything must still work — no reinstallation

---

## Verify the Database Directly

```bash
# Connect as root
docker exec -it mariadb mysql -u root -p
# Enter MYSQL_ROOT_PASSWORD from .env

SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT user_login, user_email FROM wp_users;
EXIT;

# Connect as WordPress user
docker exec -it mariadb mysql -u wpuser -p wordpress
# Enter MYSQL_PASSWORD from .env — must succeed
```

---

## Common Debug Commands

```bash
# Check which process is PID 1 in each container
docker exec nginx cat /proc/1/cmdline | tr '\0' ' '
docker exec wordpress cat /proc/1/cmdline | tr '\0' ' '
docker exec mariadb cat /proc/1/cmdline | tr '\0' ' '

# Test TLS versions (1.0 and 1.1 must fail, 1.2 and 1.3 must succeed)
openssl s_client -connect achanek.42.fr:443 -tls1    # must fail
openssl s_client -connect achanek.42.fr:443 -tls1_1  # must fail
openssl s_client -connect achanek.42.fr:443 -tls1_2  # must succeed
openssl s_client -connect achanek.42.fr:443 -tls1_3  # must succeed

# Check Redis is connected from WordPress
docker exec wordpress wp redis status --allow-root --path=/var/www/html

# Check no forbidden options exist
grep -r "network: host" srcs/
grep -r "links:" srcs/
grep -r "sleep infinity" srcs/
grep -r "tail -f" srcs/
```