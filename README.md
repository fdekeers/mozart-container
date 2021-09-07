# Docker container for Mozart 1.4.0

This repository contains the files to build and run
the Oz development environment, [Mozart 1.4.0](http://mozart2.org/mozart-v1/),
inside a Docker container.

The 1.4.0 version of Mozart provides the most functionality,
but its maintenance has been stopped,
and it only exists as a 32-bit program.
To overcome this, and allow it to run on the widest range of platforms,
this repository provides a Docker image to run Mozart 1.4.0 on multiple platforms.

For Mozart 1.4.0 documentation, please visit
http://mozart2.org/mozart-v1/doc-1.4.0/.

## Docker image

This branch `main` only contains a [Dockerfile] describing the Docker image used to build instances of the container.
This image is also available on Docker Hub (https://hub.docker.com/r/fdekeers/mozart-1.4.0),
and can be pulled with the following command:
```shell
docker pull fdekeers/mozart-1.4.0
```

## Installation

To use the Docker container, Docker must be installed on the computer.
To this end, please visit Docker's installation instructions for your machine:
https://docs.docker.com/get-docker/. Note : Docker for Windows will require you to install WSL on your computer, which steps are described in the Docker installation guide for Windows.

Additionally, to run the script to build and deploy the container,
Python must be installed.
Please follow the instructions on the Python website:
https://www.python.org/downloads/.

Afterwards, please switch to the branch corresponding to your host platform
to build and run the container, and profit from the power of
[Mozart 1.4.0](http://mozart2.org/mozart-v1/).

## Support for different platforms

The image has been tested and approved on the following platforms:
- Linux
    - Ubuntu 20.04, 18.04, 16.04
    - Debian 11
    - Fedora 34, 33
    - Centos 8, 7
- Windows
    - Windows 10
- MacOS