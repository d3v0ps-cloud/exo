# Use Python 3.11 slim as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    clang \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . .

# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

ENV DEBUG=1
ENV CLANG=0
ENV CUDA=1
ENV NV=1
ENV GPU=1

# Upgrade pip and install dependencies
RUN pip install --no-cache-dir -U pip setuptools wheel torch llvmlite
RUN pip install --no-cache-dir -e .

# Set the entrypoint
ENTRYPOINT ["exo"]
