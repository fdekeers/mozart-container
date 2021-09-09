# Docker container for Mozart 1.4.0 - MacOS

**Contributors: DEFRERE Sacha, DE KEERSMAEKER François, KUPERBLUM Jérémie** \
**Date: Sep. 9, 2021** \
**Git: https://github.com/fdekeers/mozart-container/tree/macos**

This repository contains the setup files to build and run
the Oz development environment, [Mozart 1.4.0](http://mozart2.org/mozart-v1/),
inside a Docker container, for a MacOS operating system.

The 1.4.0 version of Mozart provides the most functionality,
but its maintenance has been stopped,
and it only exists as a 32-bit program.
To overcome this, and allow it to run on the widest range of platforms,
this repository provides a Docker image to run Mozart 1.4.0 on multiple platforms.

You can find here [Documentation for Mozart 1.4.0](http://mozart2.org/mozart-v1/doc-1.4.0/).

## Basic usage

### Prerequisites

To use the Docker container, Docker must be installed on the computer.
To this end, please visit [Docker's installation instructions for MacOS](https://docs.docker.com/desktop/mac/install/).

Additionally, to run the script to build and deploy the container,
Python must be installed.
Please follow the instructions on the [Python website](https://www.python.org/downloads/).
If you have [Xcode](https://developer.apple.com/xcode/) installed,
Python is already included.

### Use the container

First of all, make sure the Docker daemon is running on your machine. You can do this simply by launching the Docker Desktop application.

Download the repository files as a ZIP, by clicking the green *Code* button
on the top right corner, then the *Download ZIP* button, and extract it.
Take the application bundle,
[Mozart_Programming_Interface.app](Mozart_Programming_Interface.app)
inside the newly created directory `mozart-container-macos`,
and move it to your application folder, `/Applications`.

To launch the Mozart 1.4.0 container, you can then simply double-click on the
[Mozart_Programming_Interface.app](Mozart_Programming_Interface.app)
application bundle, or search for it with Spotlight.
This will launch the container with the default options.
To customize those options, or if you encounter problems,
please read the following section.

A directory will be shared between the host and the container.
Any modification made to one side (host or container) of this directory,
will be also visible on the other side.
This allows modifying files, for example Oz source code files,
outside of the container, and access them inside of it.
By default, this directory is found at the path `~/Desktop/oz-files` on the host (it is created if it does not exist), and at the path `/root/oz-files` inside the container.

To exit the Mozart 1.4.0 container, exit the Mozart window, and type
`exit`, or `CTRL+D` inside the container terminal.


## Customization and troubleshooting

If you want to somewhat customize the container, or if you encounter some problems,
please read this section.

### Python script for customization

When double-clicking on the [application bundle](Mozart_Programming_Interface.app),
a Python script ([build.py](Mozart_Programming_Interface.app/Contents/MacOS/build.py))
is run with the default values for the command line options.
To customize those options, the script can be run directly from a terminal.

To access the script, right-click on the [application bundle](Mozart_Programming_Interface.app)
and inspect the files of the application.
Go to `Mozart_Programming_Interface.app/Contents/MacOS`,
and run the script with the following command:
```shell
$ python build.py [-d SHARED_DIR_HOST] [-n INSTANCE_NAME] [-p PORT_MAPPING]
```
(or `python3`, `py`, ... instead of `python` to suit your python command)

The `-d` option allows to provide the path of a host directory
that will be shared with the container.
This directory can be used, for example, to store Oz source code files.
Inside the container, this directory will be located in `/root/DIR_BASENAME`.
If the argument is not specified, the default host directory to be shared is
`~/Desktop/oz-files`, which will be created if not present.
Any modification made to one of those directories will be applied to the other too.


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

Note: Additional necessary tools are installed during the execution of the script:
- [Homebrew](https://brew.sh/index_fr), a package manager to install other software
- `socat`, a tool to forward sockets
- A [X11](https://en.wikipedia.org/wiki/X_Window_System) server for MacOS,
    [XQuartz](https://www.xquartz.org/),
    that provides GUI capabilities to applications inside containers.
- `wmctrl`, a tool to manage the GUI windows


### Access to the container shell

When the container is launched, a Mozart window is directly opened.
However, the container shell stays open, such that advanced users can
run shell commands inside the container.

It is also possible to open other Mozart windows from the container shell,
with the command `oz`, however this will launch the Mozart process in the foreground,
and the shell will not be accessible anymore.
To launch other Mozart processes in the background, run the following command
into the container shell:
```console
# nohup oz &> /dev/null &
```

### Display problems with multiple screens

If you are using multiple screens in "extend" mode,
the Mozart window may be out of reach, because it is spawned outside of
the screen limits.
To overcome this issue, two solutions are possible,
depending on which Mozart window it is:
- Mozart window launched when the container starts:
During the starting phase of the container, a white `xterm` window will spawn
on the screen. Clicking on this window will move the first Mozart window on it,
and it will thus be accessible.
- All other upcoming Mozart windows, started with the `oz` command
from within the container: Switch the multi-display mode to "mirror",
move the Mozart window in reach, then switch back to "extend" mode.

## Support for different platforms

- Tested on BigSur 11.2, should be supported on other versions too

## Limitations

In Oz, when binding a socket on a port, the port can be chosen automatically in the range of available ports,
which is 32768 – 60999 (according to https://en.wikipedia.org/wiki/Ephemeral_port
and observation), with the following instruction, where `X` is a declared but not assigned variable:
```oz
{Server bind(port:X)}
```

However, as *host networking* is not available or MacOS
(https://docs.docker.com/network/host/), this would require to map this entire
range of ports to host ports, in order to accomodate all the possible ports.
This is untractable, and this instruction can therefore not be used on the
MacOS versions of the container.
Instead, the port to bind to can be set by the programmer with the following
instruction, where `PortNumber` is the number of the port:
```oz
{Server bind(takePort:PortNumber)}
```

In this way, only the port used for binding must be published to the host,
with the command line option `-p` of the deployment script.
