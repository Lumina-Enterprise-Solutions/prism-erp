.PHONY: help
help: ## Display this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Initial setup for development environment
	@echo "Setting up development environment..."
	@./scripts/setup-dev.sh

.PHONY: setup-cluster
setup-cluster: ## Create kind cluster
	@echo "Creating kind cluster..."
	@./scripts/setup-cluster.sh

.PHONY: lint
lint: lint-go lint-proto ## Run all linters

.PHONY: lint-go
lint-go: ## Run Go linter
	@echo "Running Go linter..."
	@golangci-lint run ./...

.PHONY: lint-proto
lint-proto: ## Run Proto linter
	@echo "Running Proto linter..."
	@buf lint

.PHONY: test-all
test-all: test-unit test-integration ## Run all tests

.PHONY: test-unit
test-unit: ## Run unit tests
	@echo "Running unit tests..."
	@go test -v -race -cover ./... -tags=unit

.PHONY: generate
generate: generate-proto ## Generate all code

.PHONY: generate-proto
generate-proto: ## Generate code from proto files
	@echo "Generating proto code..."
	@buf generate

.PHONY: up
up: ## Start development environment with Tilt
	@echo "Starting development environment..."
	@tilt up

.PHONY: down
down: ## Stop development environment
	@echo "Stopping development environment..."
	@tilt down

.PHONY: create-service
create-service: ## Create a new service (usage: make create-service name=service-name)
	@go run tools/create_service.go -name=$(name)
