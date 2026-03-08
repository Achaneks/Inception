# USER_DOC — User Documentation

## What Services Are Running?

| Service | Role | Access |
|---|---|---|
| **NGINX** | Web server + HTTPS | Port 443 (only entry point) |
| **WordPress** | Website / CMS | Via `https://login.42.fr` |
| **MariaDB** | Database | Internal only (no external port) |

---

## Start and Stop the Stack

```bash
# Start everything (build if needed)
make

# Stop all containers
make down

# Restart and rebuild
make re
```

---

## Access the Website

1. Make sure `/etc/hosts` contains: `127.0.0.1 login.42.fr`
2. Open your browser and go to: `https://login.42.fr`
3. Click **Advanced → Accept the risk** (self-signed certificate warning is normal)
4. The WordPress website will load

**Admin panel**: `https://login.42.fr/wp-admin`
- Login with the admin credentials from `srcs/.env`

---

## Manage Credentials

All credentials are stored in `srcs/.env`. Open it to find:
- `WP_ADMIN_USER` / `WP_ADMIN_PASSWORD` — WordPress admin login
- `WP_USER` / `WP_USER_PASSWORD` — Regular editor login
- `MYSQL_USER` / `MYSQL_PASSWORD` — WordPress database user
- `MYSQL_ROOT_PASSWORD` — MariaDB root password

> ⚠️ Never commit `srcs/.env` to Git. It is in `.gitignore`.

---

## Check That Services Are Running

```bash
# See all running containers and their status
make status

# Follow live logs from all services
make logs

# Check a specific service
docker logs nginx
docker logs wordpress
docker logs mariadb
```

All three containers should show status `Up`.
