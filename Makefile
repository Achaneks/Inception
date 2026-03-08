NAME		= inception
LOGIN		= achanek

DATA_DIR	= /home/$(LOGIN)/data
WP_DATA		= $(DATA_DIR)/wordpress
DB_DATA		= $(DATA_DIR)/mariadb

COMPOSE		= docker compose -f srcs/docker-compose.yml

all: dirs
	$(COMPOSE) up -d --build

dirs:
	@mkdir -p $(WP_DATA)
	@mkdir -p $(DB_DATA)

down:
	$(COMPOSE) down

re: down all

clean: down
	docker system prune -af

fclean: clean
	@sudo rm -rf $(WP_DATA)
	@sudo rm -rf $(DB_DATA)
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

.PHONY: all dirs down re clean fclean status logs