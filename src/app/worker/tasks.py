# src/app/worker/tasks.py
import time
from .celery_app import celery_app # Import the Celery app instance

@celery_app.task(bind=True) # bind=True gives access to self (the task instance)
def add(self, x: int, y: int) -> int:
    """A simple task that adds two numbers."""
    print(f"Task {self.request.id}: Adding {x} + {y}")
    time.sleep(2) # Simulate some work
    result = x + y
    print(f"Task {self.request.id}: Result = {result}")
    return result

@celery_app.task
def long_running_task(duration: int) -> str:
    """A task that simulates work for a given duration."""
    print(f"Starting long task for {duration} seconds...")
    time.sleep(duration)
    print("Long task finished.")
    return f"Completed after {duration} seconds."

# Example of a task that might interact with DB or external services
# from app.core.db import get_session # Assuming you set up DB sessions
# @celery_app.task
# def process_data(item_id: int) -> bool:
#     with get_session() as db:
#         # Fetch item from DB
#         # Process item
#         # Update item status
#         pass
#     return True