# src/app/models/base.py
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy import MetaData
from typing import Any

# Recommended naming convention for primary keys, indexes, etc.
# See: https://alembic.sqlalchemy.org/en/latest/naming.html
convention = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}

# Create a metadata object with the naming convention
metadata = MetaData(naming_convention=convention)

# Base class for all models
class Base(DeclarativeBase):
    metadata = metadata # Use the metadata with naming convention
    id: Any # Default primary key type hint placeholder
    __name__: str # For better error messages

    # Generate __tablename__ automatically
    # @declared_attr.directive
    # def __tablename__(cls) -> str:
    #     return cls.__name__.lower() + "s" # Simple pluralization (customize if needed)