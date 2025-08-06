# syntax=docker/dockerfile:1

FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.source=https://github.com/rdkcentral/docker-rdk-ci
LABEL org.opencontainers.image.authors="RDK Engineers"
LABEL org.opencontainers.image.description="RDK CI Docker Image"
LABEL org.opencontainers.image.architectures="amd64, arm64"

# Add instructions to install autotools
RUN apt-get update && apt-get install -y build-essential \
          wget openssl tar vim git git-lfs \
          libtool autotools-dev automake zlib1g-dev ninja-build meson \
          libglib2.0-dev python3-distutils libcurl4-openssl-dev \
          libmsgpack-dev libsystemd-dev libssl-dev libcjson-dev python3-pip libsqlite3-dev \
          libgtest-dev libgmock-dev libjansson-dev libbsd-dev tcl-dev \
          libboost-all-dev libwebsocketpp-dev libcunit1 libcunit1-dev libunwind-dev libcap-dev libdbus-1-dev libavro-dev\
          gdb valgrind lcov clang g++ wget gperf ruby-full curl

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
