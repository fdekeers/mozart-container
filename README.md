# Docker container for Mozart 1.4.0

This repository contains the setup files to build and run
the Oz development environment, [Mozart 1.4.0](http://mozart2.org/mozart-v1/),
inside a Docker container, on a Windows operating system.

The 1.4.0 version of Mozart provides the most functionality,
but its maintenance has been stopped,
and it only exists as a 32-bit program.
To overcome this, and allow it to run on the widest range of platforms,
this repository provides a Docker image to run Mozart 1.4.0 on multiple platforms.

You can find here [Documentation for Mozart 1.4.0](http://mozart2.org/mozart-v1/doc-1.4.0/).

## Prerequisites

To use the Docker container, Docker must be installed on the computer.
To this end, please visit [Docker's installation instructions for Windows](https://docs.docker.com/desktop/windows/install/). Note : Docker for Windows will require you to install WSL on your computer, which steps are described in the given link.

Additionally, to run the script to build and deploy the container,
Python must be installed.
Please follow the instructions on the [Python website](https://www.python.org/downloads/).


## Build and run instances of the container

First of all, make sure the Docker daemon is running on your machine. You can do this simply by launching the Docker Desktop application.

A Python script ([build.py](./build.py)) is provided to ease the building and deployment of instances of the container.
To run this script, simply run it with Python in this directory, with the following command:
```shell
python build.py [-d SHARED_DIR_HOST] [-n INSTANCE_NAME] [-p PORT_MAPPING]
```
(or `python3`, `py`, ... instead of `python` to suit your python command)

You can also simply double-click on the [windows.bat](./windows.bat)
batch file to run the deployment script and build and run the container,
with the default values for the optional command line arguments,
that will be described below.
You can not move the batch file, but you can create a shortcut to it
that you can place wherever you want on your Windows machine. An icon is given in the [resources](resources) folder if you want your shortcut to have a Mozart appearence.

The `-d` option allows to provide the path of a host directory
that will be shared with the container.
This directory can be used, for example, to store Oz source code files.
Inside the container, this directory will be located in `/root/DIR_BASENAME`.
If the argument is not specified, the default host directory to be shared is
`./oz-files`, which will be created if not present. NB : the files you create/modify and save on the container directory will be saved in the host directory too.

The `-n` option allows to provide the name to give to the container instance.
Please note that two running instances can not have the same name.
If the argument is not specified, the default value is `mozart-1.4.0_n`,
where `n` is the index of this instance, starting from 0.

The `-p` option allows to provide the port mappings between the host ports
and the container ports, with the syntax `host_port:container_port`.
More precisely, this means that, for every mapping,
the port `container_port` inside the container can be accessed from
the host port `host_port`.
To provide multiple mappings, simply provide this option multiple times. NB : since multiple instances cannot be mapped to the same ports, if you plan on running more than one container you must override the default mappings with the `-p` option.
If this option is not specified, the default port mappings are
the following:
- 9000:9000
- 33000:33000
- 34000:34000
- 35000:35000
- 36000:36000

Note:

On Windows, the deployment script will first download and install the
[X11](https://en.wikipedia.org/wiki/X_Window_System) server for Windows,
[VcXsrv](https://sourceforge.net/projects/vcxsrv/),
that provides GUI capabilities to applications inside containers.
Please keep the default installation directory,
`C:\Program Files\VcXsrv`.

## Limitations

In Oz, when binding a socket on a port, the port can be chosen automatically in the range of available ports,
which is 32768 – 60999 (according to https://en.wikipedia.org/wiki/Ephemeral_port
and observation), with the following instruction, where `X` is a declared but not assigned variable:
```oz
{Server bind(port:X)}
```

However, as *host networking* is not available on Windows
(https://docs.docker.com/network/host/), this would require to map this entire
range of ports to host ports, in order to accomodate all the possible ports.
This is untractable, and this instruction can therefore not be used on the
Windows version of the container.
Instead, the port to bind to can be set by the programmer with the following
instruction, where `PortNumber` is the number of the port:
```oz
{Server bind(takePort:PortNumber)}
```

In this way, only the port used for binding must be published to the host,
with the command line option `-p` of the deployment script.