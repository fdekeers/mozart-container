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

# Install Mozart 1.4.0 (following instructions from https://github.com/mozart/mozart/tree/master)
RUN mkdir -p /tmp/mozart
WORKDIR /tmp/mozart
RUN git clone https://github.com/mozart/mozart src
RUN mkdir build
WORKDIR build
RUN ../src/configure --prefix=/usr/mozart --disable-contrib-gdbm
RUN make
RUN make install
ENV OZHOME=/usr/mozart
ENV PATH=$PATH:$OZHOME/bin
RUN rm -rf /tmp/mozart

# Create and switch to unprivileged user
RUN groupadd -g 999 user
RUN useradd -r -u 999 -g user user
RUN mkdir /home/user
RUN chmod og+rwx /home/user
USER user
WORKDIR /home/user

# Run Mozart inside the container
CMD oz
