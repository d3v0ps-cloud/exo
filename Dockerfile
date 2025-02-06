FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Set CUDA environment variables for runtime
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Set environment variables
# ENV PATH=/usr/local/python3.12/bin:$PATH

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-dev \
    python3-venv \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    build-essential \
    pkg-config \
    cmake \
    gcc \
    make \
    libopenblas-dev \
    liblapack-dev \
    liblapacke-dev \
    libssl-dev \
    libffi-dev \
    python3-cffi \
    python3-cryptography \
    curl \
    git \
    libgl1-mesa-glx && \
    rm -rf /var/lib/apt/lists/*

# Install CUDA development packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cuda-command-line-tools-12-4 \
    cuda-compiler-12-4 \
    cuda-cudart-dev-12-4 \
    cuda-nvcc-12-4 && \
    rm -rf /var/lib/apt/lists/*

# Verify Python installation and install pip
RUN python3 --version && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3 && \
    rm -f get-pip.py && \
    python3 -m pip --version

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

# Install Python package dependencies one by one for better error visibility
RUN pip install --no-cache-dir --upgrade pip

# Install build and setup tools first
RUN pip install --no-cache-dir wheel
RUN pip install --no-cache-dir setuptools
RUN pip install --no-cache-dir distutils-extra

# Install core dependencies with all necessary build tools
RUN pip install --no-cache-dir --no-binary :all: cffi
RUN pip install --no-cache-dir --no-binary :all: pycparser
RUN pip install --no-cache-dir --no-binary :all: cryptography

# Ensure scapy installs with all dependencies
RUN pip install --no-cache-dir 'setuptools>=65.5.1'
RUN pip install --no-cache-dir scapy==2.6.1

# Install remaining packages
RUN pip install --no-cache-dir nvidia-ml-py==12.560.30

# Install the package itself with verbose output and ignore installed
RUN pip install --no-cache-dir --ignore-installed -v .

# RUN pip install --no-cache-dir --no-deps mlx-lm==0.18.2

CMD ["exo", "--inference-engine", "tinygrad", "--disable-tui"]
