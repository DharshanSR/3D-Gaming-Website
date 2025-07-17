# 3D Gaming Website - Makefile
# Convenient commands for development and deployment

.PHONY: help setup dev build test docker-build docker-run k8s-deploy k8s-cleanup clean

# Default target
.DEFAULT_GOAL := help

# Colors
GREEN  := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
BLUE   := $(shell tput setaf 4)
RESET  := $(shell tput sgr0)

## Help
help: ## Show this help message
	@echo "$(BLUE)3D Gaming Website - Available Commands$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'

## Setup and Development
setup: ## Setup development environment
	@echo "$(YELLOW)Setting up development environment...$(RESET)"
	@chmod +x scripts/*.sh
	@./scripts/setup.sh

dev: ## Start development server
	@echo "$(YELLOW)Starting development server...$(RESET)"
	@./scripts/dev.sh

dev-docker: ## Start development server with Docker
	@echo "$(YELLOW)Starting development server with Docker...$(RESET)"
	@./scripts/dev.sh --docker

install: ## Install dependencies
	@echo "$(YELLOW)Installing dependencies...$(RESET)"
	@npm install

## Building
build: ## Build for production
	@echo "$(YELLOW)Building for production...$(RESET)"
	@./scripts/build.sh

build-docker: ## Build Docker image
	@echo "$(YELLOW)Building Docker image...$(RESET)"
	@./scripts/build.sh --docker

## Testing and Quality
test: ## Run all tests and quality checks
	@echo "$(YELLOW)Running tests and quality checks...$(RESET)"
	@./scripts/test.sh

lint: ## Run ESLint
	@echo "$(YELLOW)Running ESLint...$(RESET)"
	@./scripts/test.sh --lint

format: ## Check code formatting
	@echo "$(YELLOW)Checking code formatting...$(RESET)"
	@./scripts/test.sh --format

format-fix: ## Fix code formatting
	@echo "$(YELLOW)Fixing code formatting...$(RESET)"
	@npx prettier --write src/

security: ## Check for security vulnerabilities
	@echo "$(YELLOW)Checking for security vulnerabilities...$(RESET)"
	@./scripts/test.sh --security

## Docker Operations
docker-run: ## Run Docker container locally
	@echo "$(YELLOW)Running Docker container...$(RESET)"
	@docker run -p 3000:80 3d-gaming-website:latest

docker-compose-up: ## Start with Docker Compose
	@echo "$(YELLOW)Starting with Docker Compose...$(RESET)"
	@docker-compose up --build

docker-compose-down: ## Stop Docker Compose
	@echo "$(YELLOW)Stopping Docker Compose...$(RESET)"
	@docker-compose down

## Kubernetes Operations
k8s-setup: ## Setup Minikube and Kubernetes environment
	@echo "$(YELLOW)Setting up Kubernetes environment...$(RESET)"
	@./scripts/deploy-local.sh --setup

k8s-deploy: ## Deploy to local Kubernetes
	@echo "$(YELLOW)Deploying to Kubernetes...$(RESET)"
	@./scripts/deploy-local.sh --full

k8s-status: ## Check Kubernetes deployment status
	@echo "$(YELLOW)Checking Kubernetes deployment status...$(RESET)"
	@./scripts/deploy-local.sh --status

k8s-cleanup: ## Remove Kubernetes deployment
	@echo "$(YELLOW)Cleaning up Kubernetes deployment...$(RESET)"
	@./scripts/deploy-local.sh --cleanup

## Cleanup
clean: ## Clean build artifacts and dependencies
	@echo "$(YELLOW)Cleaning up...$(RESET)"
	@rm -rf dist/
	@rm -rf node_modules/
	@docker system prune -f
	@echo "$(GREEN)Cleanup completed!$(RESET)"

## CI/CD
ci: ## Run CI pipeline locally
	@echo "$(YELLOW)Running CI pipeline...$(RESET)"
	@make install
	@make lint
	@make test
	@make build

validate-workflows: ## Validate GitHub Actions workflows
	@echo "$(YELLOW)Validating GitHub Actions workflows...$(RESET)"
	@./scripts/validate-workflows.sh

## Quick Start
quick-start: ## Quick start for new developers
	@echo "$(BLUE)🚀 Quick Start for 3D Gaming Website$(RESET)"
	@make setup
	@make install
	@make dev
