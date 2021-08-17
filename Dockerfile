# Dockerfile describing the container used to run
# Mozart 1.4.0 on 64-bit architectures.
#
# Author: François De Keersmaeker

# Base image: 32-bit CentOS 7
FROM i386/centos:7

# Update/install needed packages
RUN yum update -y
RUN yum install -y gcc
RUN yum install -y gcc-c++
RUN yum install -y make
RUN yum install -y wget
RUN yum install -y git
RUN yum install -y emacs
RUN yum install -y flex
RUN yum install -y bison
RUN yum install -y tk-devel

# Download and install Mozart 1.4.0
WORKDIR /usr/local
#RUN wget https://rpmfind.net/linux/atrpms/sl5-i386/atrpms/testing/gmp-4.1.4-12.3_2.el5.i386.rpm
RUN wget https://downloads.sourceforge.net/project/mozart-oz/v1/1.4.0-2008-07-03-GENERIC-i386/mozart-1.4.0.20080704-16189.i386.rpm
RUN wget https://downloads.sourceforge.net/project/mozart-oz/v1/1.4.0-2008-07-03-GENERIC-i386/mozart-doc-1.4.0.20080704-16189.i386.rpm
#RUN wget https://downloads.sourceforge.net/project/mozart-oz/v1/1.4.0-2008-07-03-GENERIC-i386/mozart-1.4.0.20080704-16189.src.rpm
