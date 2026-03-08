# DEV_DOC — Developer Documentation

## Prerequisites

- Virtual Machine running Linux (Debian/Ubuntu recommended)
- Docker Engine installed: https://docs.docker.com/engine/install/
- Docker Compose v2: `docker compose version`
- `make` installed: `apt install make`

---

## Setup From Scratch

### 1. Clone the repo
```bash
git clone <repo_url>
cd inception
```

### 2. Configure your login
Replace `login` with your actual 42 username in these files:
- `Makefile` → `LOGIN = login`
- `srcs/docker-compose.yml` → volume `device:` paths
- `srcs/requirements/nginx/conf/nginx.conf` → `server_name`
- `srcs/requirements/nginx/Dockerfile` → `-subj` CN field

### 3. Set credentials
```bash
cp srcs/.env.example srcs/.env   # if example exists, or just edit .env
vim srcs/.env
```

Fill in all values. Make sure `WP_ADMIN_USER` does **not** contain "admin".

### 4. Add host entry
```bash
echo "127.0.0.1 login.42.fr" | sudo tee -a /etc/hosts
```

### 5. Create data directories and build
```bash
make
```

This will:
- Create `/home/login/data/wordpress` and `/home/login/data/mariadb`
- Build all Docker images from Dockerfiles
- Start all containers in detached mode

---

## Makefile Commands

| Command | Description |
|---|---|
| `make` | Create dirs + build images + start containers |
| `make down` | Stop and remove containers |
| `make re` | Rebuild everything from scratch |
| `make clean` | Stop + remove all Docker images and cache |
| `make fclean` | Full clean: images + volumes + data directories |
| `make status` | Show running container status |
| `make logs` | Follow logs from all containers |

---

## Docker Compose Commands

```bash
# Start with logs visible (no -d flag)
docker compose -f srcs/docker-compose.yml up --build

# List running services
docker compose -f srcs/docker-compose.yml ps

# Enter a container shell
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash

# See logs of one service
docker compose -f srcs/docker-compose.yml logs -f wordpress
```

---

## Data Persistence

Data is stored on the host machine at:

```
/home/login/data/
├── wordpress/    ← WordPress files (wp-config.php, uploads, themes, plugins)
└── mariadb/      ← MariaDB data files (all database tables)
```

These are mounted into containers via Docker named volumes with `driver_opts`:
```yaml
driver_opts:
  type: none
  o: bind
  device: /home/login/data/wordpress
```

To verify volumes exist:
```bash
docker volume ls
docker volume inspect inception_wordpress
docker volume inspect inception_mariadb
```

To test persistence:
1. Create a WordPress post or comment via the website
2. Run `make down` then `make` again
3. Visit the site — all content must still be there
4. Reboot the VM, then `make` again — same result expected

---

## Verify Database Contents

```bash
docker exec -it mariadb mysql -u root -p
# Enter MYSQL_ROOT_PASSWORD from .env

SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT user_login, user_email, user_registered FROM wp_users;
```
