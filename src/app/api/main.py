# src/app/api/main.py
from fastapi import FastAPI, Depends, HTTPException
from pydantic import BaseModel, Field # Use Pydantic for request/response models
from typing import List, Optional

from app.core.config import Settings, get_settings

# Basic Pydantic models for request/response validation
class Item(BaseModel):
    id: int
    name: str
    description: Optional[str] = None

class PongResponse(BaseModel):
    message: str = "pong"
    environment: str
    testing: bool


# --- FastAPI App Setup ---
# Initialize FastAPI app here or in a dedicated factory function
app = FastAPI(
    title="Python Starter API",
    description="API endpoints for the starter template.",
    version="0.1.0",
    # You can add more metadata here
)


# --- Example Endpoints ---

@app.get("/ping", response_model=PongResponse, tags=["Health"])
async def ping(settings: Settings = Depends(get_settings)) -> PongResponse:
    """Simple health check endpoint."""
    return PongResponse(
        environment=settings.ENVIRONMENT,
        testing=settings.ENVIRONMENT == "test" # Example usage of settings
    )


# In-memory "database" for demonstration purposes
fake_items_db: List[Item] = [
    Item(id=1, name="Foo", description="There comes Foo"),
    Item(id=2, name="Bar", description="The bartenders"),
]

@app.get("/items", response_model=List[Item], tags=["Items"])
async def read_items(skip: int = 0, limit: int = 10) -> List[Item]:
    """Retrieve a list of items."""
    return fake_items_db[skip : skip + limit]

@app.get("/items/{item_id}", response_model=Item, tags=["Items"])
async def read_item(item_id: int) -> Item:
    """Retrieve a single item by ID."""
    item = next((item for item in fake_items_db if item.id == item_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return item

# Example endpoint showing dependency injection of settings
@app.get("/settings-example", tags=["Examples"])
async def get_settings_info(settings: Settings = Depends(get_settings)):
    """Demonstrates accessing configuration settings via dependency injection."""
    return {
        "project_name": settings.PROJECT_NAME,
        "database_url_preview": f"{settings.DATABASE_URL[:15]}...", # Be careful exposing full URLs
        "redis_host": settings.REDIS_HOST,
        "debug_mode": settings.DEBUG,
    }

# --- You would add routers here for larger applications ---
# from .routers import users, products
# app.include_router(users.router, prefix="/users", tags=["Users"])
# app.include_router(products.router, prefix="/products", tags=["Products"])

# --- Optional: Add Startup/Shutdown Events ---
@app.on_event("startup")
async def startup_event():
    print("Application startup...")
    # Initialize database connections, etc.

@app.on_event("shutdown")
async def shutdown_event():
    print("Application shutdown...")
    # Clean up resources