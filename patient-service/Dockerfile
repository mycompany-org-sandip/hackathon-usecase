# Use official Python image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose the port the app runs on
EXPOSE 8082

# Set environment variables (optional)
ENV PYTHONUNBUFFERED=1

# Command to run the application
CMD ["python", "main.py"]