FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Set CUDA environment variables for runtime
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Set environment variables
# ENV PATH=/usr/local/python3.12/bin:$PATH

# Add deadsnakes PPA for Python 3.12
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update

# Install system dependencies one by one for better error visibility
RUN apt-get update

# Install Python 3.12 and core dependencies
RUN apt-get install -y python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3.12-full \
    python3.12-lib \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-ensurepip

# Install build tools
RUN apt-get install -y build-essential \
    pkg-config \
    cmake \
    gcc \
    make

# Install library dependencies
RUN apt-get install -y libopenblas-dev \
    liblapack-dev \
    liblapacke-dev \
    libssl-dev \
    libffi-dev \
    libpython3.12-dev

# Install Python package dependencies
RUN apt-get install -y python3-dev \
    python3-cffi \
    python3-cryptography

# Install other utilities
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get install -y libgl1-mesa-glx

# Configure Python symlinks
RUN rm -rf /usr/bin/python3 && \
    ln -s /usr/bin/python3.12 /usr/bin/python3 && \
    ln -s /usr/bin/python3.12 /usr/bin/python

# Clean up
RUN apt-get clean && \
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
    python3 -c "import sys; assert sys.version_info >= (3, 12)" && \
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
