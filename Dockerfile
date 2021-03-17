FROM ubuntu:bionic


# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -q -y tzdata

RUN apt update && apt install -y wget
RUN wget https://github.com/intel/compute-runtime/releases/download/21.10.19208/intel-gmmlib_20.3.2_amd64.deb \
    && wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.6410/intel-igc-core_1.0.6410_amd64.deb \
    && wget https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.6410/intel-igc-opencl_1.0.6410_amd64.deb \
    && wget https://github.com/intel/compute-runtime/releases/download/21.10.19208/intel-opencl_21.10.19208_amd64.deb \
    && wget https://github.com/intel/compute-runtime/releases/download/21.10.19208/intel-ocloc_21.10.19208_amd64.deb \
    && wget https://github.com/intel/compute-runtime/releases/download/21.10.19208/intel-level-zero-gpu_1.0.19208_amd64.deb 

RUN dpkg -i *.deb

RUN rm *.deb

RUN apt install -y ocl-icd-* opencl-headers git mc python3-opencv build-essential cmake git pkg-config libgtk-3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy \
    libtbb2 libtbb-dev libdc1394-22-dev mesa-opencl-icd && rm -rf /var/lib/apt/lists/*

RUN useradd -rm -d /home/user -s /bin/bash -g root -G sudo -u 1001 user

USER user

WORKDIR /home/user/

RUN mkdir opencv_build && cd opencv_build && git clone https://github.com/opencv/opencv_contrib.git && cd opencv_contrib && git checkout 4.2.0

RUN cd opencv_build && git clone https://github.com/opencv/opencv.git 
RUN cd opencv_build/opencv && git checkout 4.2.0 && mkdir build 
RUN cd opencv_build/opencv/build && cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_EXTRA_MODULES_PATH=/home/user/opencv_build/opencv_contrib/modules \
    -D BUILD_EXAMPLES=OFF \
    -D WITH_OPENCL=ON .. && make -j12

USER root

RUN cd /home/user/opencv_build/opencv/build && make install

RUN rm -r /home/user/opencv_build 

USER user
