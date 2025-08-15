.PHONY: help dev prod test clean terraform-init terraform-plan terraform-apply

# Default target
help: ## Show this help message
	@echo "E-Commerce Platform Management Commands"
	@echo "======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Development
dev-start: ## Start development environment
	@echo "Starting development environment..."
	cd scripts && ./start-dev.ps1

dev-stop: ## Stop development environment
	@echo "Stopping development environment..."
	cd scripts && ./stop-dev.ps1

dev-clean: ## Clean development environment
	@echo "Cleaning development environment..."
	cd docker && make clean

# Testing
test-unit: ## Run unit tests
	@echo "Running unit tests..."
	cd scripts && ./run-tests.ps1 -TestType Unit

test-integration: ## Run integration tests
	@echo "Running integration tests..."
	cd scripts && ./run-tests.ps1 -TestType Integration

test-e2e: ## Run E2E tests
	@echo "Running E2E tests..."
	cd scripts && ./run-tests.ps1 -TestType E2E

test-all: ## Run all tests
	@echo "Running all tests..."
	cd scripts && ./run-full-tests.ps1

# Infrastructure
terraform-init: ## Initialize Terraform
	cd terraform/azure && terraform init

terraform-plan: ## Plan Terraform changes
	cd terraform/azure && terraform plan -var-file="$(ENV).tfvars"

terraform-apply: ## Apply Terraform changes
	cd terraform/azure && terraform apply -var-file="$(ENV).tfvars"

terraform-destroy: ## Destroy Terraform infrastructure
	cd terraform/azure && terraform destroy -var-file="$(ENV).tfvars"

# Kubernetes
k8s-deploy-staging: ## Deploy to staging
	kubectl apply -f kubernetes/staging/

k8s-deploy-prod: ## Deploy to production
	kubectl apply -f kubernetes/production/

k8s-rollback: ## Rollback Kubernetes deployment
	kubectl rollout undo deployment/api-gateway
	kubectl rollout undo deployment/customer-service
	kubectl rollout undo deployment/product-service
	kubectl rollout undo deployment/order-service

# Monitoring
logs: ## Show logs from all services
	cd docker && make logs

health: ## Check health of all services
	cd scripts && ./health-check.ps1

monitor: ## Open monitoring dashboard
	@echo "Opening Grafana: http://localhost:3000"
	@echo "Opening Prometheus: http://localhost:9090"
	@echo "Opening Jaeger: http://localhost:16686"

# Build
build-all: ## Build all services
	@echo "Building all services..."
	cd scripts && ./build-all.ps1

docker-build: ## Build Docker images
	cd docker && make build

docker-push: ## Push Docker images
	cd docker && make push

# Production
prod-deploy: terraform-apply k8s-deploy-prod ## Full production deployment

prod-rollback: k8s-rollback ## Production rollback

# Cleanup
clean: ## Clean all environments
	cd docker && make clean
	docker system prune -f
