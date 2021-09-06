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

Additionally, to run the script to build and deploy the container,
Python must be installed.
Please follow the instructions on the [Python website](https://www.python.org/downloads/).

Lastly, when cloning/downloading the zip of this version of the container, you will have to place it in your user home folder (~).

## Build and run instances of the container

A Python script ([build.py](./build.py)) is provided to ease the building and deployment of instances of the container.
To run this script, simply run it with Python in this directory, with the following command:
```shell
python build.py [-d SHARED_DIR_HOST] [-n INSTANCE_NAME] [-p PORT_MAPPING]
```
(or `python3` instead of `python` to suit your OS' python command)

After the first usage with the python command, which also acts as an installation, there will also be a desktop launcher linked with the container (placed in ~/.local/share/applications/), which will allow you to launch the container simply by searching and running the Mozart_Programming_Interface application.

The `-d` option allows to provide the path of a host directory
that will be shared with the container.
This directory can be used, for example, to store Oz source code files.
Inside the container, this directory will be located in `/root/DIR_BASENAME`.
If the argument is not specified, the default host directory to be shared is
`./oz-files`, which will be created if not already existing.

The `-n` option allows to provide the name to give to the container instance.
Please note that two running instances can not have the same name.
If the argument is not specified, the default value is `mozart-1.4.0_n`,
where `n` is the index of this instance, starting from 0.

The `-p` option allows to provide the port mappings between the host ports
and the container ports, with the syntax `host_port:container_port`.
More precisely, this means that, for every mapping,
the port `container_port` inside the container can be accessed from
the host port `host_port`.
This option is ignored on Linux, since *host networking* is used,
which means that the container uses the host network stack directly,
and thus that the host and container share IP addresses and ports.
To provide multiple mappings, simply provide this option multiple times.
If this option is not specified, the default port mappings are
the following:
- 9000:9000
- 33000:33000
- 34000:34000
- 35000:35000
- 36000:36000

Note:

The user that runs the script must have `sudo` rights.

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


## Limitations

In Oz, when binding a socket on a port, the port can be chosen automatically in the range of available ports,
which is 32768 – 60999 (according to https://en.wikipedia.org/wiki/Ephemeral_port
and observation), with the following instruction, where `X` is a declared but not assigned variable:
```oz
{Server bind(port:X)}
```

However, as *host networking* is not available on Windows or MacOS
(https://docs.docker.com/network/host/), this would require to map this entire
range of ports to host ports, in order to accomodate all the possible ports.
This is untractable, and this instruction can therefore not be used on the
Windows or MacOS versions of the container.
Instead, the port to bind to can be set by the programmer with the following
instruction, where `PortNumber` is the number of the port:
```oz
{Server bind(takePort:PortNumber)}
```

In this way, only the port used for binding must be published to the host,
with the command line option `-p` of the deployment script.