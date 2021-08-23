# Docker container for Mozart 1.4

This repository contains the setup files to build and run
the Oz development environment, [Mozart 1.4](http://mozart2.org/mozart-v1/),
inside a Docker container.

The 1.4 version of Mozart proposes the most functionality,
but its maintenance has been stopped,
and it only exists as a 32-bit program.
To overcome this, and allow it to run on the widest range of platforms,
this repository provides a Docker image to run Mozart 1.4 on multiple platforms.

For Mozart documentation, please visit
http://mozart2.org/mozart-v1/doc-1.4.0/.

## Prerequisites

To use the Docker container, Docker must be installed on the computer.
To this end, please visit Docker's installation instructions for your machine:
https://docs.docker.com/get-docker/.

Additionally, if your machine is using Windows, Python 3 must be installed.
Please follow the instructions on the Python website:
https://www.python.org/downloads/.

## Build and run the container

Scripts are provided to ease the building and deployment of the container,
depending on the host platform:
- Linux: Bash script [build.sh](build.sh)
- Windows: Python script [build.py](build.py)

The container will share a directory with the host machine,
which can be used to store the Oz source code files.
By default, this directory is located at the following path:
- `./oz-files` on the host
- `/root/oz-files` inside the container

Another host directory can be chosen to be shared,
by specifying its path as an optional command line argument.
In that case, the shared folder will be placed in
`/root/FOLDER_BASENAME` inside the container.

To summarize, the Mozart 1.4 container can be built and deployed with the following commands:
- Linux:
```
./build.sh [OZ_FOLDER_HOST]
```
    **Warning**: the user that runs the Linux script must have `sudo` rights.

- Windows:
```
python build.py [OZ_FOLDER_HOST]
```

- MacOS:
```
```

To use a GUI, the Windows script will first download and install the
[X11](https://en.wikipedia.org/wiki/X_Window_System) server for Windows,
[VcXsrv](https://sourceforge.net/projects/vcxsrv/),
that provides GUI capabilities to applications inside containers.
Please keep the default installation directory,
`C:\Program Files\VcXsrv`.


## Support for different platforms

The image has been tested and approved on the following platforms:
- Windows
    - Windows 10
- Mac OS
- Linux
    - Ubuntu 20.04
    - CentOS