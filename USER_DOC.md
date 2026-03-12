# USER_DOC — User Documentation

## What Services Are Running?

The Inception stack provides the following services:

| Service | Role | How to Access |
|---|---|---|
| **NGINX** | HTTPS entry point, reverse proxy | Port 443 only |
| **WordPress** | Website and content management system | https://achanek.42.fr |
| **MariaDB** | Relational database | Internal only (not accessible from outside) |
| **Redis** | Object cache for WordPress speed | Internal only |
| **FTP (vsftpd)** | File access to WordPress volume | ftp://127.0.0.1 port 21 |
| **Adminer** | Web-based database management UI | https://achanek.42.fr/adminer/ |
| **Portfolio** | Static personal website | https://achanek.42.fr/portfolio/ |
| **Grafana** | Monitoring dashboard | https://achanek.42.fr/grafana/ |

---

## Start and Stop the Project

```bash
# Start everything (builds images if needed)
make

# Stop all containers (data is preserved)
make down

# Restart everything
make re

# Full cleanup — removes containers, images, and all data
make fclean
```

Wait **60–90 seconds** after `make` before opening the browser — WordPress installs itself automatically on first startup.

---

## Access the Website

**Before first use**, make sure this line is in `/etc/hosts`:
```
127.0.0.1 achanek.42.fr
```

Add it if missing:
```bash
echo "127.0.0.1 achanek.42.fr" | sudo tee -a /etc/hosts
```

Open your browser and go to `https://achanek.42.fr`.

You will see a **certificate warning** — this is normal and expected because we use a self-signed SSL certificate. Click **Advanced → Accept Risk and Continue**.

**WordPress admin panel:** `https://achanek.42.fr/wp-admin`

Log in with the admin credentials from `srcs/.env` (`WP_ADMIN_USER` / `WP_ADMIN_PASSWORD`).

---

## Locate and Manage Credentials

All credentials are stored in `srcs/.env`:

```bash
cat srcs/.env
```

| Credential | Variable | Used For |
|---|---|---|
| WordPress admin login | `WP_ADMIN_USER` / `WP_ADMIN_PASSWORD` | wp-admin panel |
| WordPress editor login | `WP_USER` / `WP_USER_PASSWORD` | Regular site login |
| Database user | `MYSQL_USER` / `MYSQL_PASSWORD` | WordPress ↔ MariaDB |
| Database root | `MYSQL_ROOT_PASSWORD` | Direct MariaDB access |
| FTP login | `FTP_USER` / `FTP_PASSWORD` | FTP file access |
| Grafana login | `admin` / `grafanapass123` | Grafana dashboard |

> ⚠️ Never commit `srcs/.env` to Git. It is listed in `.gitignore`.

### Create the `.env` file

Copy and paste this entire .env:
```bash
# ─── Domain ────────────────────────────────────────────────
DOMAIN_NAME=achanek.42.fr

# ─── MariaDB ───────────────────────────────────────────────
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=wppassword123
MYSQL_ROOT_PASSWORD=rootpassword123

# ─── WordPress ─────────────────────────────────────────────
WP_TITLE=My Inception Site

# Admin (must NOT contain 'admin')
WP_ADMIN_USER=sitemaster
WP_ADMIN_PASSWORD=adminpass123
WP_ADMIN_EMAIL=sitemaster@achanek.42.fr

# Regular user
WP_USER=editor
WP_USER_PASSWORD=editorpass123
WP_USER_EMAIL=editor@achanek.42.fr

# ─── FTP (Bonus) ───────────────────────────────────────────
FTP_USER=ftpuser
FTP_PASSWORD=ftppass123

# ─── Grafana (Bonus) ───────────────────────────────────────
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=grafanapass123
EOF
```

Verify it was created correctly:
```bash
cat srcs/.env
```

---

## Check That Services Are Running

```bash
# See all containers and their status
docker ps

# All 8 containers should show "Up":
# nginx, wordpress, mariadb, redis, ftp, adminer, website, grafana
```

Check individual service logs:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
docker logs redis
docker logs ftp
```

Check Redis cache is connected:
```bash
docker exec wordpress wp redis status --allow-root --path=/var/www/html
# Expected: Status: Connected
```

Check the website responds:
```bash
curl -k https://achanek.42.fr
# Expected: HTML starting with <!DOCTYPE html>
```

---

## Access Bonus Services

**Adminer** (database UI): `https://achanek.42.fr/adminer/`
- System: MySQL
- Server: `mariadb`
- Username: `wpuser`
- Password: from `MYSQL_PASSWORD` in `.env`
- Database: `wordpress`

**FTP** (file access to WordPress):
```bash
ftp 127.0.0.1
# Username: ftpuser (FTP_USER from .env)
# Password: ftppass123 (FTP_PASSWORD from .env)
```

**Grafana** (monitoring): `https://achanek.42.fr/grafana/`
- Username: `admin`
- Password: `grafanapass123`

**Portfolio**: `https://achanek.42.fr/portfolio/`
- No login required — static page