# Dockerfile describing the container used to run
# Mozart 1.4.0 on 64-bit architectures.
#
# Author: François De Keersmaeker

# Base image: 32-bit Debian 11
FROM i386/debian:bullseye

# Update/install needed packages
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y emacs
RUN apt-get install -y flex
RUN apt-get install -y bison
RUN apt-get install -y tk-dev
RUN apt-get install -y build-essential
RUN apt-get install -y g++-multilib
RUN apt-get install -y zlib1g-dev:i386
RUN apt-get install -y libgmp-dev:i386

# Install Mozart 1.4.0 (following instructions on https://github.com/mozart/mozart)

# Working directory
#WORKDIR mozart