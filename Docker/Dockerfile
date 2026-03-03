FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    build-essential \
    cmake \
    git \
    wget \
    fftw3-dev \
    libfftw3-dev \
    libgsl-dev \
    vim \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install GROMACS 2024.4
RUN wget ftp://ftp.gromacs.org/gromacs/gromacs-2024.4.tar.gz && \
    tar xfz gromacs-2024.4.tar.gz && \
    cd gromacs-2024.4 && \
    mkdir build && cd build && \
    cmake .. \
      -DGMX_GPU=CUDA \
      -DGMX_BUILD_OWN_FFTW=ON \
      -DGMX_MPI=OFF \
      -DCMAKE_INSTALL_PREFIX=/usr/local/gromacs && \
    make -j22 && \
    make install

ENV PATH="/usr/local/gromacs/bin:$PATH"

WORKDIR /data
