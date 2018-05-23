# based on kaixhin/cuda-theano

# Start with cuDNN base image
FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu14.04
MAINTAINER Ye Xia <yexia@berkeley.edu>

# Install git, wget, python-dev, pip, BLAS + LAPACK and other dependencies
RUN apt-get update && apt-get install -y \
  gfortran \
  git \
  wget \
  liblapack-dev \
  libopenblas-dev \
  python-dev \
  python-pip \
  python-nose \
  python-numpy \
  python-scipy

# Remove OS-installed six
RUN rm /usr/lib/python2.7/dist-packages/six*

# Set CUDA_ROOT
ENV CUDA_ROOT /usr/local/cuda/bin

# Install CMake 3
RUN cd /root && wget http://www.cmake.org/files/v3.8/cmake-3.8.1.tar.gz && \
  tar -xf cmake-3.8.1.tar.gz && cd cmake-3.8.1 && \
  ./configure && \
  make -j "$(nproc)" && \
  make install

# Install Cython
RUN pip install Cython

# Clone libgpuarray repo and move into it
RUN cd /root && git clone https://github.com/Theano/libgpuarray.git && cd libgpuarray && \
# Make and move into build directory
  mkdir Build && cd Build && \
# CMake
  cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr && \
# Make
  make -j"$(nproc)" && \
  make install
# Install pygpu
RUN cd /root/libgpuarray && \
  python setup.py build_ext -L /usr/lib -I /usr/include && \
  python setup.py install

# Install Theano
RUN pip install pip==9.0.3
RUN pip install --upgrade six
RUN pip install Theano==0.9.0

