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

# Create and switch to unprivileged user
RUN groupadd -g 999 user
RUN useradd -r -u 999 -g user user
RUN mkdir /home/user
RUN chmod og+rwx /home/user
USER user
WORKDIR /home/user

# Install Mozart 1.4.0 (following instructions from https://github.com/mozart/mozart/tree/master)
RUN mkdir -p /home/user/dev/mozart
WORKDIR /home/user/dev/mozart
RUN git clone https://github.com/mozart/mozart
RUN mkdir build
WORKDIR build
RUN ../mozart/configure --prefix=/home/user/oz --disable-contrib-gdbm
RUN make
RUN make install
ENV OZHOME=/home/user/oz
ENV PATH=$PATH:$OZHOME/bin
