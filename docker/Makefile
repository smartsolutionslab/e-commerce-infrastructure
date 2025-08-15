.PHONY: help start stop restart build logs clean health

# Default target
help: ## Show this help message
	@echo "E-Commerce Platform Docker Commands"
	@echo "=================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

start-infra: ## Start infrastructure services only
	docker-compose -f docker-compose.infrastructure.yml up -d
	@echo "Waiting for services to be ready..."
	@sleep 30
	@make health-infra

start-services: ## Start application services
	docker-compose -f docker-compose.services.yml up -d
	@echo "Waiting for services to be ready..."
	@sleep 30
	@make health-services

start-all: ## Start all services (infrastructure + applications)
	@make start-infra
	@make start-services

stop: ## Stop all services
	docker-compose -f docker-compose.services.yml down
	docker-compose -f docker-compose.infrastructure.yml down

restart: ## Restart all services
	@make stop
	@make start-all

build: ## Build all service images
	docker-compose -f docker-compose.services.yml build --no-cache

logs: ## Show logs from all services
	docker-compose -f docker-compose.infrastructure.yml -f docker-compose.services.yml logs -f

logs-infra: ## Show logs from infrastructure services
	docker-compose -f docker-compose.infrastructure.yml logs -f

logs-services: ## Show logs from application services
	docker-compose -f docker-compose.services.yml logs -f

clean: ## Clean up containers, networks, and volumes
	docker-compose -f docker-compose.services.yml down -v
	docker-compose -f docker-compose.infrastructure.yml down -v
	docker system prune -f

health-infra: ## Check health of infrastructure services
	@echo "Checking infrastructure services health..."
	@docker ps --filter "label=com.docker.compose.project=ecommerce-infrastructure" --format "table {{.Names}}\t{{.Status}}"

health-services: ## Check health of application services
	@echo "Checking application services health..."
	@docker ps --filter "label=com.docker.compose.project=ecommerce-services" --format "table {{.Names}}\t{{.Status}}"

health: ## Check health of all services
	@make health-infra
	@make health-services

dev: ## Start development environment
	@echo "Starting E-Commerce development environment..."
	@make start-infra
	@echo "Infrastructure services started. Start application services manually for development."
