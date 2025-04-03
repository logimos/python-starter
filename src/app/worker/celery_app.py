# src/app/worker/celery_app.py
from celery import Celery
from app.core.config import settings

# Initialize Celery
# The first argument is the name of the current module (__name__)
# The broker and backend are taken from the settings object
celery_app = Celery(
    "worker",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=["app.worker.tasks"], # List of modules containing tasks
)

# Optional Celery configuration
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    # You might want different settings for production
    # task_acks_late = True
    # worker_prefetch_multiplier = 1
)

if __name__ == "__main__":
    # Allows running the worker directly using: python -m app.worker.celery_app worker ...
    celery_app.start()