# Dockerfile describing the container used to run
# Mozart 1.4.0 on 64-bit architectures.
#
# Author: François De Keersmaeker

# Base image: 32-bit Debian 11
FROM i386/debian:bullseye

# Update/install needed packages
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

# Install Mozart 1.4.0
COPY mozart-1.4.0.20080704-linux-i486.tar.gz /usr/local
WORKDIR /usr/local
RUN gzip -cd mozart-1.4.0.20080704-linux-i486.tar.gz | tar xvf -
RUN rm -f mozart-1.4.0.20080704-linux-i486.tar.gz
ENV PATH="${PATH}:/usr/local/mozart/bin"

# Working directory
#WORKDIR mozart