# Docker container for Mozart 1.4

This repository contains the setup files to build and run
the Oz development environment, [Mozart 1.4](http://mozart2.org/mozart-v1/),
inside a Docker container.

The 1.4 version of Mozart proposes the most functionality,
but its maintenance has been stopped,
and it only exists as a 32-bit program.
To overcome this, and allow it to run on the widest range of platforms,
this repository provides a Docker image to run Mozart 1.4 on multiple platforms.

## Prerequisites

To use the Docker container, Docker must be installed on the computer.
To this end, please visit Docker's installation instructions for your machine:
https://docs.docker.com/get-docker/.

Additionally, if your machine is using Windows, Python 3 must be installed.
Please follow the instructions on the Python website:
https://www.python.org/downloads/.

## Build and run the container

Linux:
```
./build.sh $OZ_FILES_FOLDER
```

Windows:
```
python build.py $OZ_FILES_FOLDER
```

## Support for different platforms

The image has been tested and approved on the following platforms:
- Windows
    - Windows 10
- Mac OS
- Linux
    - Ubuntu 20.04
    - CentOS