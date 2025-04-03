# Makefile for Python + Poetry + Nix + Docker

# Variables
POETRY := poetry
PYTHON := $(POETRY) run python
SRC_DIR := src/app
TEST_DIR := tests

# Default target
.DEFAULT_GOAL := help

.PHONY: help install lock update lint format test test-cov clean \
	docker-build docker-up docker-down docker-logs docker-prune \
	nix-shell nix-update nix-clean \
	run-api run-worker db-migrate db-upgrade db-current

help: ## Show this help message
	@echo "Usage: make <target>"
	@echo
	@echo "Poetry/Python targets:"
	@awk 'BEGIN {FS = ":.*##"; printf "  \033[36m%-20s\033[0m %s\n", "Target", "Description"} \
	/^[a-zA-Z0-9_-]+:.*##/ { \
	    if ($$2 ~ /Poetry|Python|lint|format|test|run-|db-/) \
	    {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2} \
	}' $(MAKEFILE_LIST)
	@echo
	@echo "Docker targets:"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_-]+:.*##/ { \
	    if ($$2 ~ /Docker/) \
	    {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2} \
	}' $(MAKEFILE_LIST)
	@echo
	@echo "Nix targets:"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_-]+:.*##/ { \
	    if ($$2 ~ /Nix/) \
	    {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2} \
	}' $(MAKEFILE_LIST)


## --- Poetry/Python targets ---
install: ## [Poetry] Install dependencies from poetry.lock
	$(POETRY) install

lock: ## [Poetry] Update poetry.lock file without installing
	$(POETRY) lock --no-update

update: ## [Poetry] Update dependencies to latest allowed versions and update lock file
	$(POETRY) update

lint: install ## [Python] Run linters (Ruff) and type checker (Mypy)
	$(POETRY) run ruff check $(SRC_DIR) $(TEST_DIR)
	$(POETRY) run mypy $(SRC_DIR) $(TEST_DIR)

format: install ## [Python] Format code using Ruff
	$(POETRY) run ruff format $(SRC_DIR) $(TEST_DIR)

test: install ## [Python] Run tests using Pytest
	$(POETRY) run pytest $(TEST_DIR)

test-cov: install ## [Python] Run tests with coverage report
	$(POETRY) run pytest --cov=$(SRC_DIR) --cov-report=term-missing $(TEST_DIR)

run-api: install ## [Python] Run the FastAPI development server locally
	$(POETRY) run uvicorn app.api.main:app --reload --host 0.0.0.0 --port 8000

run-worker: install ## [Python] Run the Celery worker locally
	$(POETRY) run celery -A app.worker.celery_app worker --loglevel=info

db-migrate: install ## [Python] Create a new Alembic migration script
	$(POETRY) run alembic revision --autogenerate -m "New migration"

db-upgrade: install ## [Python] Apply pending Alembic migrations to the database
	$(POETRY) run alembic upgrade head

db-current: install ## [Python] Show current Alembic migration revision
	$(POETRY) run alembic current

clean: ## [Python] Remove Python artifacts
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +
	rm -rf .pytest_cache .mypy_cache .coverage build dist *.egg-info


## --- Docker targets ---
docker-build: ## [Docker] Build docker images using docker-compose
	docker compose build

docker-up: ## [Docker] Start services using docker-compose in detached mode
	docker compose up --detach

docker-down: ## [Docker] Stop and remove containers, networks defined in docker-compose
	docker compose down

docker-logs: ## [Docker] Follow logs from docker-compose services
	docker compose logs --follow

docker-prune: ## [Docker] Remove stopped containers and dangling images
	docker container prune -f
	docker image prune -f


## --- Nix targets ---
nix-shell: ## [Nix] Enter the Nix development shell
	nix develop

nix-update: ## [Nix] Update flake inputs
	nix flake update

nix-clean: ## [Nix] Run garbage collection
	nix-collect-garbage -d