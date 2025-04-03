# Dockerfile

# --- Builder Stage ---
# Use official Python base image corresponding to pyproject.toml
FROM python:3.10-slim as builder

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    # Poetry settings
    POETRY_VERSION=1.8.2 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=false \
    POETRY_NO_INTERACTION=1 \
    # Path settings
    PATH="$POETRY_HOME/bin:$PATH"

# Install OS dependencies required for building Python packages if any
# (e.g., build-essential, libpq-dev for psycopg if not using binary)
# RUN apt-get update && apt-get install --no-install-recommends -y build-essential libpq-dev curl && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Set working directory
WORKDIR /app

# Copy only necessary files to leverage Docker cache
COPY poetry.lock pyproject.toml ./

# Install runtime dependencies only (no dev dependencies)
# --no-root: Do not install the project itself, only dependencies
# The virtual environment will be created in standard Poetry cache location with IN_PROJECT=false
RUN poetry install --no-dev --no-root

# --- Final Stage ---
FROM python:3.10-slim as final

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Create a non-root user and group
RUN groupadd -r appuser && useradd --no-log-init -r -g appuser appuser

# Install OS dependencies needed at runtime
# psycopg binary usually includes libpq, but postgresql-client can be useful for debugging
RUN apt-get update && apt-get install --no-install-recommends -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy virtual environment from builder stage
# Need to find the correct path where Poetry installed the venv
# Usually ~/.cache/pypoetry/virtualenvs/ or /opt/pysetup/.venv if POETRY_VIRTUALENVS_PATH was set
# Find the venv path (this might need adjustment based on actual Poetry cache location)
# Let's assume the default cache location structure (this is the trickiest part)
# We'll copy the whole cache and rely on PATH pointing to the right venv bin
COPY --from=builder /root/.cache/pypoetry/virtualenvs /root/.cache/pypoetry/virtualenvs
# Activate the venv by adding its bin to PATH (adjust if venv path is different)
# Find the specific venv dir name (it's usually based on project name and python version hash)
# This is fragile; using POETRY_VIRTUALENVS_PATH=/opt/venv in builder is more robust
# For now, let's find it dynamically (requires shell)
RUN VENV_PATH=$(find /root/.cache/pypoetry/virtualenvs -type d -name '*-py3.10' -print -quit) && \
    if [ -z "$VENV_PATH" ]; then echo "Virtualenv not found!" >&2; exit 1; fi && \
    echo "Using Venv: $VENV_PATH" && \
    ln -s "$VENV_PATH" /venv # Create a predictable symlink
ENV PATH="/venv/bin:$PATH"

# Copy application code from the current directory (.) into the container
COPY ./src /app/src

# Copy alembic config and directory
COPY alembic.ini /app/alembic.ini
COPY src/alembic /app/src/alembic

# Change ownership to non-root user
RUN chown -R appuser:appuser /app /venv /root/.cache

# Switch to non-root user
USER appuser

# Expose the port the app runs on (default for uvicorn)
EXPOSE 8000

# Run alembic migrations on startup (optional, can be done manually or via compose entrypoint)
# ENTRYPOINT ["/app/entrypoint.sh"] # If you create an entrypoint script

# Default command to run the FastAPI app with Uvicorn
# Use 0.0.0.0 to bind to all interfaces inside the container
CMD ["uvicorn", "app.api.main:app", "--host", "0.0.0.0", "--port", "8000"]



# Note: Finding the Poetry venv path in the final stage can be tricky. Setting POETRY_VIRTUALENVS_PATH=/opt/venv in the builder stage makes copying easier. Add ENV POETRY_VIRTUALENVS_PATH=/opt/venv to the builder and change the COPY and ENV PATH lines in the final stage accordingly.