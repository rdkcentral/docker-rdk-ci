# syntax=docker/dockerfile:1

FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.source=https://github.com/rdkcentral/docker-rdk-ci
LABEL org.opencontainers.image.authors="RDK Engineers"
LABEL org.opencontainers.image.description="RDK CI Docker Image"
LABEL org.opencontainers.image.architectures="amd64, arm64"


# Add PPA for gcc-9 and g++-9
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/ppa -y \
    && apt-get update


# Install all required system packages
RUN apt-get install -y \
    build-essential cmake ninja-build meson \
    wget curl openssl tar vim git git-lfs \
    libtool autotools-dev automake zlib1g-dev \
    libglib2.0-dev libcurl4-openssl-dev libmsgpack-dev \
    libsystemd-dev libssl-dev libcjson-dev libsqlite3-dev \
    libgtest-dev libgmock-dev libjansson-dev libjansson4 \
    libbsd-dev tcl-dev libboost-all-dev libwebsocketpp-dev \
    libcunit1 libcunit1-dev libunwind-dev libcap-dev libdbus-1-dev \
    libavro-dev libusb-1.0-0-dev libjsoncpp-dev libwebsockets-dev \
    libdirectfb-dev net-tools netcat-openbsd psmisc gdb valgrind lcov clang \
    g++ g++-9 gcc-9 ruby-full csvtool lynx autoconf gperf pipx \
    python3-pip python3-setuptools python3-flake8 python3-pandas python3-bs4 \
    python3-colorama \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install Python packages
RUN pipx install peru

# Install Python packages
RUN pipx install websockets

# Install Python packages
RUN pipx install flask

# Install Python packages
RUN pipx install jsonref


# Common python packages
RUN pip3 install xmltodict requests jsonref

RUN gem install ceedling

# Commands that needs to be executed on container
RUN mkdir -p WORK_DIR
RUN cd WORK_DIR
RUN wget https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3.tar.gz
RUN tar -zxvf cmake-3.17.3.tar.gz

RUN cd cmake-3.17.3/ && ./bootstrap && make && make install

# Clean up all source and build artifacts
RUN cd .. && rm -rf WORK_DIR && rm -rf cmake-3.17.3.tar.gz && rm -rf cmake-3.17.3

# Install gtest libraries
RUN cd /usr/src/googletest/googlemock/ && mkdir build && cmake .. && make && make install

RUN mkdir -p /home/mount

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get install -q -y nodejs

# Trim down the docker image size
RUN rm -rf /var/lib/apt/lists/*

# Install tools for publishing test results to automation
COPY gtest-json-result-push.py /usr/local/bin/gtest-json-result-push.py

CMD [ "/bin/bash" ]
