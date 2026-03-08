*This project has been created as part of the 42 curriculum by login*

---

## Description

Inception is a System Administration project that sets up a small but complete web infrastructure using **Docker** and **Docker Compose**, running entirely inside a virtual machine.

The stack consists of three services, each in its own container:
- **NGINX** — HTTPS-only entry point (TLS 1.2/1.3), reverse proxy
- **WordPress + PHP-FPM** — the web application (CMS)
- **MariaDB** — the relational database

All containers are built from **Debian Bookworm** using custom Dockerfiles. No pre-built images from Docker Hub are used. Data is persisted using Docker named volumes stored at `/home/login/data/` on the host machine.

### Project Design Choices

#### Virtual Machines vs Docker
A VM virtualizes hardware and runs a full guest OS kernel — heavy (GBs), slow to boot (minutes). A container shares the host kernel and only packages the app and its dependencies — lightweight (MBs), starts in seconds. Containers are preferred here for speed, isolation, and portability.

#### Secrets vs Environment Variables
Environment variables in `.env` are convenient but visible in shell history and process lists. Docker secrets store sensitive data in files mounted inside containers, never exposed in environment listings. For this project, `.env` is used and kept out of Git via `.gitignore`.

#### Docker Network vs Host Network
`network: host` removes all isolation — the container shares the host's network interface, defeating the purpose of containers. A custom Docker bridge network (`inception`) gives containers their own private network with built-in DNS resolution by service name.

#### Docker Volumes vs Bind Mounts
Bind mounts directly link a host path to the container. Named volumes are managed by Docker with better portability and lifecycle control. This project uses named volumes (required by the subject) pointing to `/home/login/data/` via `driver_opts`.

---

## Instructions

### Prerequisites
- Docker and Docker Compose installed
- Running inside a Virtual Machine
- `/etc/hosts` entry: `127.0.0.1 login.42.fr`
- Replace `login` with your actual 42 username in `Makefile`, `docker-compose.yml`, and `srcs/.env`

### Setup
```bash
# Clone the repository
git clone <repo_url>
cd inception

# Edit credentials
vim srcs/.env

# Build and start everything
make
```

### Access
- Website: `https://login.42.fr`
- Admin panel: `https://login.42.fr/wp-admin`

### Stop / Clean
```bash
make down     # Stop containers
make re       # Rebuild and restart
make clean    # Remove containers + images
make fclean   # Full clean including volumes and data
```

---

## Resources

### Documentation
- [Docker Official Docs](https://docs.docker.com/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress WP-CLI](https://wp-cli.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)
- [OpenSSL Self-Signed Certs](https://www.openssl.org/docs/)

### AI Usage
Claude (Anthropic) was used to:
- Understand and explain core concepts (Docker networking, TLS, PHP-FPM, FastCGI)
- Review and debug shell scripts for correctness
- Generate documentation structure (README, USER_DOC, DEV_DOC)

All generated content was reviewed, tested, and understood before use.
