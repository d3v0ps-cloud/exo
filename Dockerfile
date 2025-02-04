# Use official Python image
FROM python:3.12-slim

# Set environment variables
ENV WORKING_PORT=8080 \
    DEBUG=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy installation files
COPY setup.py .

# Install exo
RUN pip3 install --no-cache-dir . && \
    pip3 cache purge

# Copy source code
# TODO: Change this to copy only the necessary files
COPY . .

# either use ENV NODE_ID or generate a random node id
RUN if [ -z "$NODE_ID" ]; then export NODE_ID=$(uuidgen); fi

# Run command
CMD ["python3", "main.py", "--disable-tui", "--node-id", "$NODE_ID"]

# Expose port
EXPOSE $WORKING_PORT
