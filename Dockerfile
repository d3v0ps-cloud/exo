# Use Python 3.11 slim as base
#FROM python:3.11-slim
FROM nvidia/cuda:12.5.1-cudnn-runtime-ubuntu22.04

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    clang \
    python3.12 \
    python3.12-dev \
    python3.12-distutils \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . .

# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install dependencies
RUN pip install --no-cache-dir -U pip setuptools wheel torch llvmlite
RUN pip install --no-cache-dir -e .

# Set the entrypoint
ENTRYPOINT ["exo"]
