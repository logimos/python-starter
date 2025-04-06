# src/app/models/item.py
from sqlalchemy import String, Integer, Text
from sqlalchemy.orm import Mapped, mapped_column
import datetime

from .base import Base # Import the Base class

class Item(Base):
    """Example SQLAlchemy model"""
    __tablename__ = "items" # Explicitly define table name

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(100), index=True, nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime.datetime] = mapped_column(default=datetime.datetime.utcnow)
    updated_at: Mapped[datetime.datetime] = mapped_column(
        default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow
    )