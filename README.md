
# Python Starter Template

This project is a starter template for Python applications using FastAPI, Celery, SQLAlchemy, and Docker. It includes a basic API, worker, and database setup.

## 🛠️ Usage (Makefile Targets)

The `Makefile` provides convenient shortcuts for common tasks. Run `make help` to see all available targets. Key targets include:

**Dependency Management (Poetry):**
*   `make install`: Install Python dependencies from `poetry.lock`.
*   `make lock`: Update `poetry.lock` based on `pyproject.toml` (no install).
*   `make update`: Update Python dependencies to latest allowed versions and update `poetry.lock`.

**Linting & Formatting:**
*   `make lint`: Run Ruff linter and Mypy type checker.
*   `make format`: Format code using Ruff formatter.

**Testing:**
*   `make test`: Run tests using Pytest.
*   `make test-cov`: Run tests and generate a coverage report.

**Running Locally (Requires `nix develop`):**
*   `make run-api`: Start the FastAPI development server with hot-reloading.
*   `make run-worker`: Start the Celery worker locally.

**Database Migrations (Alembic):**
*   `make db-migrate`: Generate a new migration script based on model changes (edit message!).
*   `make db-upgrade`: Apply pending migrations to the database (requires Docker DB running).
*   `make db-downgrade`: Revert the last migration.
*   `make db-current`: Show the current migration version applied to the database.
*   `make db-history`: Show the full migration history.

**Docker:**
*   `make docker-build`: Build the Docker images for the application services.
*   `make docker-up`: Start all services defined in `docker-compose.yml` in detached mode.
*   `make docker-down`: Stop and remove containers, networks defined in `docker-compose.yml`.
*   `make docker-logs`: Follow logs from running Docker containers.
*   `make docker-prune`: Remove stopped containers and dangling Docker images to free up space.

**Nix:**
*   `make nix-shell`: Alias for `nix develop`.
*   `make nix-update`: Update Nix flake inputs (e.g., `nixpkgs`).
*   `make nix-clean`: Run Nix garbage collection.

## 🔄 Development Workflow

1.  **Enter Environment:** Start Docker services (`make docker-up`) and enter the Nix shell (`nix develop`).
2.  **Code:** Make changes to your application code in `src/app/`.
3.  **Lint/Format:** Run `make format` and `make lint` periodically to ensure code quality and type safety. Fix any reported issues.
4.  **Test:** Run `make test` or `make test-cov` to ensure your changes pass tests and maintain coverage. Write new tests for new features.
5.  **Database Changes (If necessary):**
    *   Modify SQLAlchemy models in `src/app/models/`.
    *   Generate a migration script: `make db-migrate` (update the `-m "..."` message in the Makefile or command).
    *   **Review the generated script** in `src/alembic/versions/` carefully.
    *   Apply the migration: `make db-upgrade`.
6.  **Commit:** Add your changes and any new migration scripts to Git (`git add .`, `git commit ...`).
7.  **Repeat.**

## ⚙️ Configuration

Application settings are managed using `pydantic-settings` in `src/app/core/config.py`.

*   Settings are loaded from environment variables.
*   Environment variables can be conveniently defined in a `.env` file in the project root during development.
*   The `.env.example` file shows available settings. Copy it to `.env` and customize.
*   **Never commit your `.env` file.**

## 🗄️ Database Migrations

Alembic is used to manage database schema changes.

1.  Modify your SQLAlchemy models under `src/app/models/`.
2.  Generate a new migration script: `make db-migrate` (customize the message).
3.  **Review the generated Python script** in `src/alembic/versions/`. This is crucial.
4.  Apply the migration to your running database: `make db-upgrade`.
5.  Commit both your model changes and the new migration script.

## 🐳 Running with Docker

While `make run-api` and `make run-worker` are useful for rapid development with hot-reloading, you can also run the entire application stack using Docker Compose, which is closer to a production environment.

*   `make docker-build`: Build fresh images.
*   `make docker-up`: Start the API, worker, DB, Redis, and Flower containers.
*   Access the API at `http://localhost:8000`.
*   Access Flower at `http://localhost:5555`.
*   `make docker-logs`: View combined logs from all services.
*   `make docker-down`: Stop and remove all application containers.

## 🧪 Testing

Tests are located in the `tests/` directory and use `pytest`.

*   Run all tests: `make test`
*   Run tests with coverage: `make test-cov` (configuration in `pyproject.toml`)

## ✨ Linting & Formatting

Code style and quality are enforced using Ruff and Mypy.

*   Check formatting, linting, and types: `make lint`
*   Automatically format code: `make format`
*   Configuration for these tools is in `pyproject.toml` under `[tool.ruff]` and `[tool.mypy]`.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details (or state MIT License directly if no separate file).