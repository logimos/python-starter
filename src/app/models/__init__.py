# src/app/models/__init__.py
# This makes it easier to import models and ensures they are loaded by SQLAlchemy
from .base import Base
from .item import Item  

# Add other models here as you create them
# from .user import User