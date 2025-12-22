# syntax=docker/dockerfile:1

FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.source=https://github.com/rdkcentral/docker-rdk-ci
LABEL org.opencontainers.image.authors="RDK Engineers"
LABEL org.opencontainers.image.description="RDK CI Docker Image"
LABEL org.opencontainers.image.architectures="amd64, arm64"

# Add instructions to install autotools
RUN apt-get update && apt-get install -y \
    automake build-essential clang curl g++ gcc gdb git git-lfs gperf iputils-ping jq lcov libavro-dev \
    libbsd-dev libc6-dev libcjson-dev libcap-dev libcurl4-openssl-dev libdbus-1-dev libgmock-dev libgtest-dev \
    libglib2.0-dev libjansson-dev liblog4c-dev libmsgpack-dev libnetfilter-queue-dev libnfnetlink-dev libsqlite3-dev \
    libssl-dev libsystemd-dev libtirpc-dev libtool libunwind-dev libwebsocketpp-dev libxml2-utils libcunit1 libcunit1-dev \
    meson net-tools ninja-build openssl python3-distutils python3-pip ruby-full tar tcl-dev valgrind vim wget libmnl-dev \
    zlib1g-dev libupnp-dev libnanomsg-dev libevent-dev libnl-3-dev libnl-route-3-dev libnl-nf-3-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

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
