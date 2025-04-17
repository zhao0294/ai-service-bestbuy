# # Use the official Python image as the base image
# FROM python:3.12.4-alpine

# # Install the required system packages
# RUN apk update && \
#     apk add --no-cache gcc musl-dev libffi-dev
# # Set the working directory to /app
# WORKDIR /app

# # Set the build argument for the app version number
# ARG APP_VERSION=0.1.0

# # Copy the requirements file into the container
# COPY requirements.txt .

# # Install the dependencies
# # RUN pip install --no-cache-dir -r requirements.txt
# RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt
# # Copy the rest of the application code into the container

# COPY . .

# # Expose port 5001 for the FastAPI application
# EXPOSE 5001

# # Set the environment variable for the app version number
# ENV APP_VERSION=$APP_VERSION

# # Start the FastAPI application
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5001"]

# Base image
FROM python:3.11-slim AS base

WORKDIR /app

# Builder stage
FROM base AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y gcc g++ libffi-dev libssl-dev build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Final stage
FROM base AS final

# Copy installed dependencies from builder
COPY --from=builder /usr/local /usr/local

# Copy application code
COPY . .

# Set environment variable for app version
ARG APP_VERSION=0.1.0
ENV APP_VERSION=$APP_VERSION

# Expose port
EXPOSE 5001

# Run Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5001"]
