# Docker container for Mozart 1.4.0

This repository contains the setup files to build and run
the Oz development environment, [Mozart 1.4.0](http://mozart2.org/mozart-v1/),
inside a Docker container, on a Linux operating system.

The 1.4.0 version of Mozart provides the most functionality,
but its maintenance has been stopped,
and it only exists as a 32-bit program.
To overcome this, and allow it to run on the widest range of platforms,
this repository provides a Docker image to run Mozart 1.4.0 on multiple platforms.

You can find here [Mozart 1.4.0 documentation](http://mozart2.org/mozart-v1/doc-1.4.0/).

## Prerequisites

To use the Docker container, Docker must be installed on the computer.
To this end, please visit Docker's [installation instructions for Linux](https://docs.docker.com/engine/install/).

To be able to run Docker, and thus to use the Mozart 1.4.0 container,
`sudo` rights are required.

Additionally, to run the script to build and deploy the container,
Python must be installed.
Please follow the instructions on the [Python website](https://www.python.org/downloads/).

## Installation

The Mozart 1.4.0 container can be installed as a Linux desktop application,
such that it can be launched by simply clicking its icon in the list of applications.
To install the application, please run the [install.sh](install.sh) script
at the root of this repository, with the following command:
```shell
$ ./install.sh
```

After the installation, an application named "Mozart Programming Interface" will
be placed in the list of applications.
Simply click on it to launch the container.

A directory will be shared between the host and the container,
such that files can be modified outside of the container,
but accessed inside of it.
By default, this directory is found at the path `~/oz-files` on the host
(it is created if it does not exist),
and at the path `/root/oz-files` inside the container.

This application actually runs a Python script
([build.py](build.py))
that builds and deploys the container with the default options.
This script, and its command line options, are described in more detail below,
if you want more precise parameterization of the container.

## Python script for container deployment

A Python script ([build.py](./build.py)) is provided to ease the building and deployment of instances of the container.
To run this script, simply run it with Python3 in this directory, with the following command:
```shell
$ python3 build.py [-d SHARED_DIR_HOST] [-n INSTANCE_NAME]
```

The `-d` option allows to provide the path of a host directory
that will be shared with the container.
This directory can be used, for example, to store Oz source code files.
Inside the container, this directory will be located in `/root/DIR_BASENAME`.
If the argument is not specified, the default host directory to be shared is
`~/oz-files`, which will be created if not already existing. NB : the files you create/modify and save on the container directory will be saved in the host directory too.

The `-n` option allows to provide the name to give to the container instance.
Please note that two running instances can not have the same name.
If the argument is not specified, the default value is `mozart-1.4.0_n`,
where `n` is the index of this instance, starting from 0.

Notes:
- There is no port mapping option unlike for Windows and MacOS, because the container will use host networking (only supported on Linux), which means that the container uses the host network stack directly, and thus that the host and container share IP addresses and ports.
- The user that runs the script must have `sudo` rights.

## Supported platforms

The image has been tested and approved on the following platforms:
- Ubuntu 20.04, 18.04, 16.04
- Debian 11
- Fedora 34, 33
- Centos 8, 7