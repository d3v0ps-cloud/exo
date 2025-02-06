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

# Install Python 3.12 and dependencies
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
    libffi-dev \
    libssl-dev \
    libpython3.12-dev \
    python3.12-distutils && \
    rm -rf /usr/bin/python3 && \
    ln -s /usr/bin/python3.12 /usr/bin/python3 && \
    ln -s /usr/bin/python3.12 /usr/bin/python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install CUDA development packages needed for building
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-command-line-tools-12-4 \
    cuda-compiler-12-4 \
    cuda-cudart-dev-12-4 \
    cuda-nvcc-12-4 \
    && rm -rf /var/lib/apt/lists/*

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

# Install Python package dependencies one by one for better error visibility
RUN pip install --no-cache-dir --upgrade pip

RUN pip install --no-cache-dir wheel setuptools

# Install CFFI and Cryptography with required dependencies
RUN pip install --no-cache-dir --no-binary :all: cffi

RUN pip install --no-cache-dir --no-binary :all: cryptography

RUN pip install --no-cache-dir nvidia-ml-py==12.560.30

# Install the package itself
RUN pip install --no-cache-dir -v .

# RUN pip install --no-cache-dir --no-deps mlx-lm==0.18.2

CMD ["exo", "--inference-engine", "tinygrad", "--disable-tui"]
