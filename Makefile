# ===========================================
# WP-STUDIO MAKEFILE
# ===========================================
# Quick commands for team workflow
# Usage: make <command>

.PHONY: help up down restart fresh logs shell wp node composer build-plugin build-theme test lint

# Colors for output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

help: ## Show this help
	@echo "$(GREEN)WP-Studio Available Commands:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(RESET) %s\n", $$1, $$2}'

## ===========================================
## Docker Commands
## ===========================================

up: ## Start the studio
	@echo "$(GREEN)Starting WP-Studio...$(RESET)"
	docker-compose up -d
	@echo "$(GREEN)✅ Studio is running!$(RESET)"
	@echo "WordPress:  http://localhost:8000"
	@echo "Database:   http://localhost:8080"
	@echo "Emails:     http://localhost:8025"
	@echo "Redis:      localhost:6379"

down: ## Stop the studio
	@echo "$(YELLOW)Stopping WP-Studio...$(RESET)"
	docker-compose down

restart: ## Restart all containers
	@echo "$(YELLOW)Restarting...$(RESET)"
	docker-compose restart

fresh: down ## Fresh WordPress install (destroys data!)
	@echo "$(YELLOW)⚠️  This will destroy all data!$(RESET)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		docker-compose up -d; \
		echo "$(YELLOW)Waiting for services...$(RESET)"; \
		sleep 20; \
		docker-compose run --rm cli wp core install \
			--url=http://localhost:8000 \
			--title="WP Studio" \
			--admin_user=admin \
			--admin_password=admin \
			--admin_email=dev@studio.local; \
		echo "$(GREEN)✅ Fresh install complete!$(RESET)"; \
	fi

logs: ## View WordPress logs
	docker-compose logs -f wordpress

shell: ## Open WordPress bash shell
	docker-compose exec wordpress bash

## ===========================================
## WP-CLI Commands
## ===========================================

wp: ## Run WP-CLI command (e.g., make wp CMD="plugin list")
	docker-compose run --rm cli wp $(CMD)

install-woo: ## Install and activate WooCommerce
	@echo "$(GREEN)Installing WooCommerce...$(RESET)"
	docker-compose run --rm cli wp plugin install woocommerce --activate
	docker-compose run --rm cli wp plugin install wordpress-importer --activate
	@echo "$(GREEN)✅ WooCommerce installed!$(RESET)"

install-redis: ## Install Redis Object Cache plugin
	@echo "$(GREEN)Installing Redis Object Cache...$(RESET)"
	docker-compose run --rm cli wp plugin install redis-cache --activate
	docker-compose run --rm cli wp redis enable
	@echo "$(GREEN)✅ Redis cache enabled!$(RESET)"

enable-multisite: ## Enable WordPress Multisite
	@echo "$(YELLOW)Enabling Multisite...$(RESET)"
	docker-compose run --rm cli wp core multisite-convert
	@echo "$(GREEN)✅ Multisite enabled! Update your .env file.$(RESET)"

## ===========================================
## Development Commands
## ===========================================

node: ## Open Node.js shell
	docker-compose run --rm node sh

composer: ## Run Composer command (e.g., make composer CMD="require vendor/package")
	docker-compose run --rm composer $(CMD)

build-plugin: ## Build plugin assets (e.g., make build-plugin NAME=my-plugin)
	@if [ -z "$(NAME)" ]; then \
		echo "$(YELLOW)Usage: make build-plugin NAME=plugin-folder-name$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Building plugin: $(NAME)$(RESET)"
	docker-compose run --rm node sh -c "cd plugins/$(NAME) && npm install && npm run build"

build-theme: ## Build theme assets (e.g., make build-theme NAME=my-theme)
	@if [ -z "$(NAME)" ]; then \
		echo "$(YELLOW)Usage: make build-theme NAME=theme-folder-name$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Building theme: $(NAME)$(RESET)"
	docker-compose run --rm node sh -c "cd themes/$(NAME) && npm install && npm run build"

watch-theme: ## Watch theme for changes (e.g., make watch-theme NAME=my-theme)
	@if [ -z "$(NAME)" ]; then \
		echo "$(YELLOW)Usage: make watch-theme NAME=theme-folder-name$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Watching theme: $(NAME)$(RESET)"
	docker-compose run --rm node sh -c "cd themes/$(NAME) && npm run dev"

## ===========================================
## Testing & Quality
## ===========================================

test: ## Run PHPUnit tests
	@echo "$(GREEN)Running tests...$(RESET)"
	docker-compose run --rm cli wp plugin list
	# Add your test commands here

lint: ## Lint PHP code (WordPress Coding Standards)
	@echo "$(GREEN)Linting PHP code...$(RESET)"
	docker-compose run --rm composer phpcs --standard=WordPress wp-content/plugins wp-content/themes

lint-fix: ## Auto-fix PHP code style issues
	@echo "$(GREEN)Fixing PHP code style...$(RESET)"
	docker-compose run --rm composer phpcbf --standard=WordPress wp-content/plugins wp-content/themes

## ===========================================
## Database & Backup
## ===========================================

db-export: ## Export database to SQL file
	@echo "$(GREEN)Exporting database...$(RESET)"
	docker-compose run --rm cli wp db export - > backup-$$(date +%Y%m%d-%H%M%S).sql
	@echo "$(GREEN)✅ Database exported!$(RESET)"

db-import: ## Import SQL file (e.g., make db-import FILE=backup.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "$(YELLOW)Usage: make db-import FILE=backup.sql$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Importing database...$(RESET)"
	docker-compose run --rm cli wp db import $(FILE)

## ===========================================
## Cleanup
## ===========================================

clean: ## Remove all containers and volumes (DESTRUCTIVE!)
	@echo "$(YELLOW)⚠️  This will destroy everything!$(RESET)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v --remove-orphans; \
		echo "$(GREEN)✅ Cleaned!$(RESET)"; \
	fi

prune: ## Remove unused Docker resources
	@echo "$(YELLOW)Pruning Docker...$(RESET)"
	docker system prune -f