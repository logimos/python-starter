# tests/test_api.py
import pytest
from httpx import AsyncClient
from fastapi import status

from app.api.main import app # Import your FastAPI app instance
from app.core.config import Settings, get_settings # Import settings components

# --- Fixtures ---

# Override settings for testing
# IMPORTANT: Create a dedicated test database if interacting with a real DB
def get_test_settings() -> Settings:
    # Load from a .env.test file or override directly
    return Settings(
        ENVIRONMENT="test",
        DEBUG=True,
        # Override DB/Redis URLs to point to test instances or disable them
        POSTGRES_USER="test_user",
        POSTGRES_PASSWORD="test_password",
        POSTGRES_SERVER="localhost", # Or a test container
        POSTGRES_DB="test_appdb",
        REDIS_HOST="localhost",     # Or a test container
        # ... other settings ...
        _env_file=None # Prevent loading .env in tests
    )

# Use FastAPI's dependency override mechanism
app.dependency_overrides[get_settings] = get_test_settings

@pytest.fixture(scope="module") # Use module scope for efficiency
async def client() -> AsyncClient:
    """Provides an async test client for the FastAPI app."""
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

# --- Tests ---

@pytest.mark.asyncio
async def test_ping(client: AsyncClient):
    """Test the /ping endpoint."""
    response = await client.get("/ping")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["message"] == "pong"
    assert data["environment"] == "test" # Verify overridden setting
    assert data["testing"] is True

@pytest.mark.asyncio
async def test_read_items(client: AsyncClient):
    """Test retrieving items."""
    response = await client.get("/items")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)
    # Check structure based on your fake_items_db or test DB setup
    assert len(data) > 0
    assert "id" in data[0]
    assert "name" in data[0]

@pytest.mark.asyncio
async def test_read_item_found(client: AsyncClient):
    """Test retrieving a specific item that exists."""
    item_id = 1 # Assuming item with ID 1 exists in your test setup
    response = await client.get(f"/items/{item_id}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == item_id
    assert data["name"] == "Foo" # Based on fake_items_db

@pytest.mark.asyncio
async def test_read_item_not_found(client: AsyncClient):
    """Test retrieving a specific item that does not exist."""
    item_id = 999 # Non-existent ID
    response = await client.get(f"/items/{item_id}")
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert response.json() == {"detail": "Item not found"}