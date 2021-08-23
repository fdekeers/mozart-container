# Dockerfile describing the container used to run
# Mozart 1.4.0 on 64-bit architectures.
#
# Author: François De Keersmaeker

# Base image: 64-bit Ubuntu 18.04
FROM ubuntu:18.04

# Prevents interactive commands when building container image
ENV DEBIAN_FRONTEND=noninteractive

# Update/Install required packages
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y wget
RUN apt-get install -y git
RUN apt-get install -y emacs
RUN apt-get install -y flex
RUN apt-get install -y bison
RUN apt-get install -y tk-dev
RUN apt-get install -y build-essential
RUN apt-get install -y g++-multilib
RUN apt-get install -y zlib1g-dev:i386
RUN apt-get install -y libgmp-dev:i386
RUN apt-get install -y libgmp3-dev:i386
RUN ln -s /usr/include/i386-linux-gnu/gmp.h /usr/include/gmp.h

# Install Mozart 1.4 (following instructions from https://github.com/mozart/mozart)
RUN mkdir -p /tmp/mozart
WORKDIR /tmp/mozart
RUN git clone https://github.com/mozart/mozart.git src
RUN mkdir build
WORKDIR build
RUN ../src/configure --prefix=/usr/mozart --disable-contrib-gdbm
RUN make
RUN make install
ENV OZHOME=/usr/mozart
ENV PATH=$PATH:$OZHOME/bin

# Install Mozart standard library (following instructions from https://github.com/mozart/mozart-stdlib)
RUN mkdir -p /tmp/mozart/stdlib
WORKDIR /tmp/mozart/stdlib
RUN git clone https://github.com/mozart/mozart-stdlib.git src
RUN mkdir build
WORKDIR build
RUN ../src/configure --prefix=/usr/mozart --disable-contrib-gdbm
RUN make
RUN make install
RUN rm -rf /tmp/mozart

# Run Mozart inside the container
WORKDIR /root
CMD oz
