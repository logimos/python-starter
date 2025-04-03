# src/app/core/config.py
import os
from functools import lru_cache
from typing import Optional

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings."""

    PROJECT_NAME: str = "Python Starter API"
    DEBUG: bool = False
    ENVIRONMENT: str = "production" # E.g., development, staging, production

    # Database Configuration
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    POSTGRES_SERVER: str
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str
    DATABASE_URL: Optional[str] = None # Assembled below or set directly

    # Redis Configuration
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0
    REDIS_URL: Optional[str] = None # Assembled below or set directly

    # Celery Configuration (uses Redis URL by default)
    CELERY_BROKER_URL: Optional[str] = None
    CELERY_RESULT_BACKEND: Optional[str] = None

    # API configuration
    API_V1_STR: str = "/api/v1"

    # Alembic migrations directory
    ALEMBIC_MIGRATION_DIR: str = "src/alembic"

    # Define model_config to specify the .env file
    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", extra="ignore"
    )

    def __init__(self, **values):
        super().__init__(**values)
        # Assemble Database URL if not explicitly set
        if self.DATABASE_URL is None:
            self.DATABASE_URL = (
                f"postgresql+psycopg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@"
                f"{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
            )
        # Assemble Redis URL if not explicitly set
        if self.REDIS_URL is None:
            self.REDIS_URL = f"redis://{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"

        # Use Redis URL for Celery if not explicitly set
        if self.CELERY_BROKER_URL is None:
            self.CELERY_BROKER_URL = self.REDIS_URL
        if self.CELERY_RESULT_BACKEND is None:
            self.CELERY_RESULT_BACKEND = self.REDIS_URL


# Use lru_cache to load settings only once
@lru_cache
def get_settings() -> Settings:
    return Settings()

settings = get_settings()