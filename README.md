*This project has been created as part of the 42 curriculum by achanek*

---

## Description

Inception is a System Administration project from the 42 curriculum. The goal is to build a complete web infrastructure using **Docker** and **Docker Compose**, running entirely inside a Virtual Machine. Every service runs in its own dedicated container, built from scratch using custom Dockerfiles based on **Debian Bookworm**.

### What the project runs

The mandatory infrastructure consists of three services:

- **NGINX** — the only entry point to the infrastructure, serving HTTPS exclusively on port 443 with TLS 1.2/1.3 and a self-signed SSL certificate
- **WordPress + PHP-FPM** — the web application, configured automatically using WP-CLI with two users (an administrator and an editor)
- **MariaDB** — the relational database storing all WordPress data

The bonus infrastructure adds five more services:

- **Redis** — object cache for WordPress, speeding up page loads by storing database query results in memory
- **vsftpd** — FTP server giving direct access to the WordPress volume for file management
- **Adminer** — lightweight single-file PHP database UI, accessible via NGINX at `/adminer/`
- **Static website** — a personal portfolio page served by its own nginx container, accessible at `/portfolio/`
- **Grafana** — monitoring and visualization dashboard, accessible at `/grafana/`

### Design choices

**Virtual Machines vs Docker**
A Virtual Machine emulates full hardware and runs a complete guest OS kernel — it is heavy (several GB), slow to boot (minutes), and resource-intensive. A Docker container shares the host kernel and only packages the application and its dependencies — it is lightweight (MB), starts in seconds, and is portable. This project uses Docker because containers provide the right level of isolation for microservices without the overhead of full VMs.

**Secrets vs Environment Variables**
Environment variables (stored in `.env`) are simple and convenient but are visible in process listings and shell history. Docker secrets store sensitive data in files mounted inside containers at runtime, never exposed as environment variables. This project uses `.env` for credentials, kept out of version control via `.gitignore`. In a production environment, Docker secrets would be the correct choice.

**Docker Network vs Host Network**
`network: host` removes all container network isolation — the container shares the host machine's network interfaces directly, which defeats the purpose of containerization. A custom Docker bridge network (`inception`) gives each container its own private IP address with DNS resolution by service name (e.g. the WordPress container reaches MariaDB simply using the hostname `mariadb`). All inter-container communication happens on this private network, invisible from the outside.

**Docker Volumes vs Bind Mounts**
A bind mount directly links a host path to a container path — simple but tightly coupled to the host filesystem structure. A named Docker volume is managed by Docker with better lifecycle control and portability. This project uses named volumes configured with `driver_opts` to bind to specific host paths (`/home/achanek/data/wordpress` and `/home/achanek/data/mariadb`), satisfying the subject requirement for named volumes while keeping data at a known host location.

---

## Instructions

### Prerequisites

- A Virtual Machine running Linux (Debian/Ubuntu recommended)
- Docker Engine installed: https://docs.docker.com/engine/install/
- Docker Compose v2: verify with `docker compose version`
- `make` installed: `sudo apt install make`
- Add the domain to `/etc/hosts`: `echo "127.0.0.1 achanek.42.fr" | sudo tee -a /etc/hosts`

### Configuration

All credentials are stored in `srcs/.env`. Edit this file before first launch:

```bash
vim srcs/.env
```

Fields to configure: domain name, MariaDB passwords, WordPress admin credentials, WordPress editor credentials, and FTP credentials (bonus).

### Running the project

```bash
# Build images and start all containers
make

# Stop all containers
make down

# Rebuild and restart everything
make re

# Full cleanup including data directories
make fclean
```

### Accessing the services

| Service | URL |
|---|---|
| WordPress site | https://achanek.42.fr |
| WordPress admin | https://achanek.42.fr/wp-admin |
| Adminer (DB UI) | https://achanek.42.fr/adminer/ |
| Portfolio | https://achanek.42.fr/portfolio/ |
| Grafana | https://achanek.42.fr/grafana/ |
| FTP | ftp://127.0.0.1 (port 21) |

The browser will show a certificate warning on first visit — this is expected for a self-signed certificate. Click **Advanced → Accept Risk and Continue**.

---

## Resources

### Official Documentation

- [Docker Engine Documentation](https://docs.docker.com/engine/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)
- [MariaDB Documentation](https://mariadb.com/kb/en/)
- [WordPress WP-CLI](https://wp-cli.org/)
- [OpenSSL Documentation](https://www.openssl.org/docs/)
- [vsftpd Documentation](http://vsftpd.beasts.org/vsftpd_conf.html)
- [Redis Documentation](https://redis.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Adminer Documentation](https://www.adminer.org/)

### Articles and Tutorials

- [Docker Networking Overview](https://docs.docker.com/network/)
- [Docker Volumes Guide](https://docs.docker.com/storage/volumes/)
- [Understanding PHP-FPM and FastCGI](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/)
- [TLS 1.2 vs TLS 1.3 Explained](https://www.a10networks.com/glossary/what-is-tls-1-3/)
- [WordPress Object Cache](https://developer.wordpress.org/reference/classes/wp_object_cache/)

### AI Usage

Claude (Anthropic) was used throughout this project for the following tasks:

- **Understanding concepts**: explaining Docker networking, TLS handshakes, FastCGI protocol, PHP-FPM pool configuration, MariaDB initialization, and Redis object caching
- **Script review**: reviewing and correcting shell scripts (`init_db.sh`, `setup_wp.sh`, `setup_ftp.sh`) for correctness and edge cases
- **Documentation**: generating the structure and content of README.md, USER_DOC.md, and DEV_DOC.md in compliance with subject requirements

All generated content was reviewed, tested, and understood before being included in the project.