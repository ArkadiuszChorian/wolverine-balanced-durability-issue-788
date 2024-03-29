.PHONY: $(MAKECMDGOALS)

DOCKER := docker
COMPOSE := docker compose

PROJECT_NAME := wolverine-balanced-durability-issue
MAKE_FLAGS := --no-print-directory
LOG_SEPARATOR := ||||||||||||||||||||||||||||||||||||||||||||||||
LOG_SEPARATOR_SHORT := |||
LOG_PRE := $(LOG_SEPARATOR)\n
LOG_POST := \n$(LOG_SEPARATOR)

all: | build up

build:
	$(COMPOSE) -p $(PROJECT_NAME) -f compose.balanced.yml build --force-rm

up:
	@$(MAKE) $(MAKE_FLAGS) log MSG="Starting PostgreSQL & RabbitMQ" up-wo-app
	@$(MAKE) $(MAKE_FLAGS) log MSG="Waiting for PostgreSQL & RabbitMQ" wait-for-postgres wait-for-rabbit
	@$(MAKE) $(MAKE_FLAGS) log MSG="Starting app (balanced mode)" up-app-balanced

down:
	$(COMPOSE) -p $(PROJECT_NAME) -f compose.balanced.yml down -t 1
	$(COMPOSE) -p $(PROJECT_NAME) down -t 1


# Up targets

up-app-balanced:
	$(COMPOSE) -p $(PROJECT_NAME) -f compose.balanced.yml up -d --force-recreate

up-app-solo:
	$(COMPOSE) -p $(PROJECT_NAME) -f compose.solo.yml up -d --force-recreate

up-wo-app: | up-rabbit up-postgres

up-postgres:
	$(COMPOSE) -p $(PROJECT_NAME) up -d --force-recreate postgres

up-rabbit:
	$(COMPOSE) -p $(PROJECT_NAME) up -d --force-recreate rabbit


# Wait targets

wait-for-postgres:
	$(COMPOSE) -p $(PROJECT_NAME) exec -T postgres /wait-for-postgres.sh

wait-for-rabbit:
	$(COMPOSE) -p $(PROJECT_NAME) exec -T postgres /wait-for-rabbit.sh


# Log targets

logs:
	$(COMPOSE) -p $(PROJECT_NAME) logs app

log:
	@echo "\n$(LOG_PRE)||| $(MSG)$(LOG_POST)\n"


# Clean targets

uninstall: clean
clear: clean
clean: | down clean-volumes clean-images

clean-volumes:
	$(DOCKER) volume rm $(PROJECT_NAME)_postgres \
		$(PROJECT_NAME)_rabbit || true

clean-images:
	$(DOCKER) rmi $$($(DOCKER) images --format '{{.Repository}}:{{.Tag}}' | grep '$(PROJECT_NAME)-') || true


# Miscellaneous

sleep:
ifdef TIME
	@sleep $(TIME)
else
	@sleep 10
endif


# Case studies

balanced-mode-step-1:
	@$(MAKE) $(MAKE_FLAGS) log MSG="Making sure it's a clean install" clean
	@$(MAKE) $(MAKE_FLAGS) log MSG="Building app image" build
	@$(MAKE) $(MAKE_FLAGS) log MSG="Starting PostgreSQL" up-postgres wait-for-postgres
	@$(MAKE) $(MAKE_FLAGS) log MSG="Starting RabbitMQ" up-rabbit wait-for-rabbit
	@$(MAKE) $(MAKE_FLAGS) log MSG="Starting app (balanced mode)" up-app-balanced
	@$(MAKE) $(MAKE_FLAGS) log MSG="Waiting for results (logs)..." sleep logs

balanced-mode-step-2:
	@$(MAKE) $(MAKE_FLAGS) log MSG="Restarting app (balanced mode)" up-app-balanced
	@$(MAKE) $(MAKE_FLAGS) log MSG="Waiting for results (logs)..." sleep logs

solo-mode-step-1:
	@$(MAKE) $(MAKE_FLAGS) log MSG="Making sure it's a clean install" clean
	@$(MAKE) $(MAKE_FLAGS) log MSG="Building app image" build
	@$(MAKE) $(MAKE_FLAGS) log MSG="Starting PostgreSQL" up-postgres wait-for-postgres
	@$(MAKE) $(MAKE_FLAGS) log MSG="Starting RabbitMQ" up-rabbit wait-for-rabbit
	@$(MAKE) $(MAKE_FLAGS) log MSG="Starting app (solo mode)" up-app-solo
	@$(MAKE) $(MAKE_FLAGS) log MSG="Waiting for results (logs)..." sleep logs