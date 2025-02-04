# nvidia: --build-arg BASE_IMAGE=nvidia/cuda:12.5.1-cudnn-runtime-ubuntu22.04
ARG BASE_IMAGE=ubuntu:jammy-20240911.1

# Base image
FROM $BASE_IMAGE

# Set environment variables
ENV WORKING_PORT=8080
ENV DEBUG=1
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Set pipefail and enable error reporting
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV PYTHONUNBUFFERED=1

# Install dependencies and Python 3.12
RUN set -x && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
    git \
    gnupg \
    build-essential \
    software-properties-common \
    curl \
    ca-certificates \
    && apt-get update -y \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://download.deadsnakes.com/key.gpg -o /etc/apt/keyrings/deadsnakes.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/deadsnakes.gpg] https://ppa.deadsnakes.com/ubuntu jammy main" > /etc/apt/sources.list.d/deadsnakes.list \
    && apt-get update -y \
    && apt-get install --no-install-recommends -y \
    python3.12-minimal \
    python3.12-dev \
    python3.12-distutils \
    python3.12-venv \
    python3.12-lib2to3 \
    && apt-get remove -y python3 python3-dev || true \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && python3.12 -V

# Install pip
RUN set -x && \
    curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.12 get-pip.py && \
    rm get-pip.py && \
    python3.12 -m pip --version

# Link python3.12 to python3 and pip3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip3 1

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
