FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables
# ENV PATH=/usr/local/python3.12/bin:$PATH

# Add deadsnakes PPA for Python 3.12
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update

# Install Python 3.12 and remove other Python versions
RUN apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    build-essential \
    pkg-config \
    cmake \
    libopenblas-dev \
    liblapack-dev \
    liblapacke-dev \
    curl \
    git \
    libgl1-mesa-glx \
    python3-cffi \
    libffi-dev && \
    rm -rf /usr/bin/python3 && \
    ln -s /usr/bin/python3.12 /usr/bin/python3 && \
    ln -s /usr/bin/python3.12 /usr/bin/python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    rm -f get-pip.py

# RUN git clone https://github.com/ml-explore/mlx.git && cd mlx && mkdir -p build && cd build && \
#     cmake .. \
#       -DCMAKE_PREFIX_PATH="/usr/lib/aarch64-linux-gnu" \
#       -DLAPACK_LIBRARIES="/usr/lib/aarch64-linux-gnu/liblapack.so" \
#       -DBLAS_LIBRARIES="/usr/lib/aarch64-linux-gnu/libopenblas.so" \
#       -DLAPACK_INCLUDE_DIRS="/usr/include" && \
#     sed -i 's/option(MLX_BUILD_METAL "Build metal backend" ON)/option(MLX_BUILD_METAL "Build metal backend" OFF)/' ../CMakeLists.txt && \
#     make -j && \
#     make install && \
#     cd .. && \
#     pip install --no-cache-dir .

COPY setup.py .
COPY exo ./exo

# Install base dependencies first
RUN pip install --no-cache-dir cffi && \
    pip install --no-cache-dir nvidia-ml-py==12.560.30 && \
    pip install --no-cache-dir .

# RUN pip install --no-cache-dir --no-deps mlx-lm==0.18.2

CMD ["exo", "--inference-engine", "tinygrad", "--disable-tui"]
