#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "Applying database migrations..."
poetry run alembic upgrade head

# Execute the command passed to the entrypoint (the Docker CMD)
exec "$@"