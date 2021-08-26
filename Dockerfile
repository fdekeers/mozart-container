# Dockerfile describing the container used to run
# Mozart 1.4.0 on 64-bit architectures.
#
# Author: Francois De Keersmaeker

# Base image: 64-bit CentOS 8
FROM centos:8

# Update/Install required packages
RUN yum update -y
RUN yum install -y glibc.i686
RUN yum install -y gcc
RUN yum install -y gcc-c++
RUN yum install -y make
RUN yum install -y wget
RUN yum install -y emacs
RUN yum install -y flex
RUN yum install -y bison
RUN yum install -y tk-devel
RUN yum install -y zlib-devel.i686
RUN yum install -y libX11-devel.i686
RUN yum install -y libnsl.i686
RUN yum install -y gmp-devel.i686
RUN ln -s /usr/lib/libgmp.so.10.4.0 /usr/lib/libgmp.so.3
RUN yum install -y net-tools

# Install Mozart 1.4.0
WORKDIR /usr
RUN wget https://downloads.sourceforge.net/project/mozart-oz/v1/1.4.0-2008-07-02-tar/mozart-1.4.0.20080704-linux-i486.tar.gz
RUN gzip -cd mozart-1.4.0.20080704-linux-i486.tar.gz | tar xvf -
# Small modification to the `ozplatform` file to consider the image arch as i486
RUN sed -i "s/unknown-unknown/linux-i486/" /usr/mozart/bin/ozplatform
ENV OZHOME=/usr/mozart
ENV PATH=$PATH:$OZHOME/bin
RUN rm -f mozart-1.4.0.20080704-linux-i486.tar.gz

WORKDIR /root
# Run Mozart without displaying error messages and while still having access to the terminal
CMD oz 2> /dev/null & /bin/bash
