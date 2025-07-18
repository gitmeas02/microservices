# Makefile for NestJS Docker Setup

.PHONY: help build up down logs clean dev prod test backup restore

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Development commands
dev: ## Start development environment
	docker-compose -f docker-compose.dev.yml up -d

dev-build: ## Build and start development environment
	docker-compose -f docker-compose.dev.yml up -d --build

dev-down: ## Stop development environment
	docker-compose -f docker-compose.dev.yml down

dev-logs: ## Show development logs
	docker-compose -f docker-compose.dev.yml logs -f

# Production commands
prod: ## Start production environment
	docker-compose -f docker-compose.prod.yml up -d

prod-build: ## Build and start production environment
	docker-compose -f docker-compose.prod.yml up -d --build

prod-down: ## Stop production environment
	docker-compose -f docker-compose.prod.yml down

prod-logs: ## Show production logs
	docker-compose -f docker-compose.prod.yml logs -f

# General commands
build: ## Build all images
	docker-compose build

up: ## Start all services (production)
	docker-compose up -d

down: ## Stop all services
	docker-compose down

logs: ## Show logs for all services
	docker-compose logs -f

restart: ## Restart all services
	docker-compose restart

status: ## Show container status
	docker-compose ps

# Database commands
db-backup: ## Backup the database
	docker-compose exec postgres pg_dump -U postgres nestjs_db > backup_$(shell date +%Y%m%d_%H%M%S).sql

db-restore: ## Restore database from backup (usage: make db-restore FILE=backup.sql)
	@if [ -z "$(FILE)" ]; then echo "Usage: make db-restore FILE=backup.sql"; exit 1; fi
	docker-compose exec -T postgres psql -U postgres nestjs_db < $(FILE)

db-shell: ## Access database shell
	docker-compose exec postgres psql -U postgres nestjs_db

db-reset: ## Reset database (WARNING: This will delete all data)
	@echo "Are you sure? This will delete all data. Press Ctrl+C to cancel or Enter to continue..."
	@read dummy
	docker-compose down
	docker volume rm nestjs_postgres_data || true
	docker-compose up -d postgres

# Application commands
app-shell: ## Access application shell
	docker-compose exec nestjs-app sh

app-test: ## Run application tests
	docker-compose exec nestjs-app npm test

app-test-e2e: ## Run end-to-end tests
	docker-compose exec nestjs-app npm run test:e2e

app-lint: ## Run linting
	docker-compose exec nestjs-app npm run lint

# Maintenance commands
clean: ## Clean up Docker resources
	docker system prune -f
	docker volume prune -f
	docker image prune -f

clean-all: ## Clean up all Docker resources (WARNING: This will remove all unused containers, networks, images)
	@echo "Are you sure? This will remove all unused Docker resources. Press Ctrl+C to cancel or Enter to continue..."
	@read dummy
	docker system prune -a -f
	docker volume prune -f

logs-tail: ## Show last 100 lines of logs
	docker-compose logs --tail=100

monitor: ## Monitor resource usage
	docker stats

# SSL commands
ssl-generate: ## Generate self-signed SSL certificates
	mkdir -p lesson1/setup/ssl
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout lesson1/setup/ssl/key.pem \
		-out lesson1/setup/ssl/cert.pem \
		-subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Quick deployment
deploy: ## Quick production deployment
	@echo "🚀 Starting production deployment..."
	docker-compose -f docker-compose.prod.yml pull
	docker-compose -f docker-compose.prod.yml build --no-cache
	docker-compose -f docker-compose.prod.yml down
	docker-compose -f docker-compose.prod.yml up -d
	@echo "✅ Deployment completed!"
	@echo "🌐 Application: http://localhost:3000"
	@echo "🏥 Health check: http://localhost:3000/health"

# Update commands
update: ## Update all Docker images
	docker-compose pull
	docker-compose -f docker-compose.prod.yml pull
	docker-compose -f docker-compose.dev.yml pull

# Environment commands
env-check: ## Check environment files
	@echo "Checking environment files..."
	@test -f lesson1/.env.production && echo "✅ .env.production exists" || echo "❌ .env.production missing"
	@test -f lesson1/.env.development && echo "✅ .env.development exists" || echo "❌ .env.development missing"

env-copy: ## Copy environment templates
	@test -f lesson1/.env.production || cp lesson1/.env.production lesson1/.env.production.example
	@test -f lesson1/.env.development || cp lesson1/.env.development lesson1/.env.development.example
	@echo "Environment files created. Please edit them with your values."
