# Docker container for Mozart 1.4.0

This repository contains the setup files to build and run
the Oz development environment, [Mozart 1.4.0](http://mozart2.org/mozart-v1/),
inside a Docker container.

The 1.4.0 version of Mozart proposes the most functionality,
but its maintenance has been stopped,
and it only exists as a 32-bit program.
To overcome this, and allow it to run on the widest range of platforms,
this repository provides a Docker image to run Mozart 1.4.0 on multiple platforms.

For Mozart 1.4.0 documentation, please visit
http://mozart2.org/mozart-v1/doc-1.4.0/.

## Prerequisites

To use the Docker container, Docker must be installed on the computer.
To this end, please visit Docker's installation instructions for your machine:
https://docs.docker.com/get-docker/.

Additionally, to run the script to build and deploy the container,
Python must be installed.
Please follow the instructions on the Python website:
https://www.python.org/downloads/.

## Build and run the container

First of all, make sure the Docker daemon is running on your machine.
(If you use Linux, it will be automatically started when deploying the container.)

A Python script ([build.py](./build.py)) is provided to ease the building and deployment of the container.
To run this script, simply run it with Python in this directory, with the following command:
```shell
python build.py [OZ_DIR_HOST]
```

The first command line argument, `OZ_DIR_HOST`, is optional,
and indicates the directory on the host that will be shared with the container.
This directory can be used to store Oz source code files.
Inside the container, this directory will be located in `/root/DIR_BASENAME`.
If the argument is not specified, the default host folder to be shared is
`./oz-files`.

Notes:
- On Linux, the user that runs the script must have `sudo` rights.
- On Windows, the deployment script will first download and install the
[X11](https://en.wikipedia.org/wiki/X_Window_System) server for Windows,
[VcXsrv](https://sourceforge.net/projects/vcxsrv/),
that provides GUI capabilities to applications inside containers.
Please keep the default installation directory,
`C:\Program Files\VcXsrv`.
- On MacOS, additional necessary tools are installed during the execution of the script:
    - [Homebrew](https://brew.sh/index_fr), a package manager to install other software
    - `socat`, a tool to forward sockets
    - A [X11](https://en.wikipedia.org/wiki/X_Window_System) server for MacOS,
    [XQuartz](https://www.xquartz.org/),
    that provides GUI capabilities to applications inside containers.

## Support for different platforms

The image has been tested and approved on the following platforms:
- Linux
    - Ubuntu 20.04, 18.04, 16.04
    - Debian 11
- Windows
    - Windows 10
- MacOS
