# Docker container for Mozart 1.4.0 - Windows

**Contributors: DEFRERE Sacha, DE KEERSMAEKER François, KUPERBLUM Jérémie** \
**Date: Sep. 10, 2021** \
**Git: https://github.com/fdekeers/mozart-container/tree/windows**

This repository contains the setup files to build and run
the Oz development environment, [Mozart 1.4.0](http://mozart2.org/mozart-v1/),
inside a Docker container, on a Windows operating system.

The 1.4.0 version of Mozart provides the most functionality,
but its maintenance has been stopped,
and it only exists as a 32-bit program.
To overcome this, and allow it to run on the widest range of platforms,
this repository provides a Docker image to run Mozart 1.4.0 on multiple platforms.

You can find here [Mozart 1.4.0 Documentation](http://mozart2.org/mozart-v1/doc-1.4.0/).


## Basic usage

### Prerequisites

To use the Docker container, Docker must be installed on the computer.
To this end, please visit [Docker's installation instructions for Windows](https://docs.docker.com/desktop/windows/install/). Note: Docker for Windows will require you to install WSL on your computer, which steps are described in the given link.

To allow the Mozart 1.4.0 container to be used with its Graphical User Interface (GUI),
a [X11](https://en.wikipedia.org/wiki/X_Window_System) server must be installed.
Please install [VcXsrv](https://sourceforge.net/projects/vcxsrv/),
a X11 server for Windows, by downloading the installer on
https://sourceforge.net/projects/vcxsrv/, and executing it.
During the installation, please keep the default installation directory,
`C:\Program Files\VcXsrv`.


### Use the container

First of all, make sure the Docker daemon is running on your machine.
You can do so by simply launching the Docker Desktop application.

Download the application executable by clicking on the *Releases* tab on the
right on the screen, then on the Windows release, and finally on the Windows
executable file `mozart-1.4.0-win.exe`.

To launch and use the Mozart 1.4.0 container, you can then simply double-click on the
`mozart-1.4.0-win.exe` executable file.
If a security message appears, stating that the application could not be trusted,
simply discard the message and run the application anyway.
This will open a terminal, the container terminal,
and after some time the Mozart Programming Interface will start.
Note: The first time the application is launched, the container image must be
downloaded, which takes some time. Please be patient !

A directory will be shared between the host and the container.
Any modification made to one side (host or container) of this directory,
will be also visible on the other side.
This allows modifying files, for example Oz source code files,
outside of the container, and access them inside of it.
By default, this directory is found at the path `C:\Users\USER\oz-files`
on the host, where USER is the name of the current user (it is created if it does not exist), and at the path `/root/oz-files` inside the container.

To exit the Mozart 1.4.0 container, exit the Mozart window, and type
`exit`, or `CTRL+D` inside the container terminal.


## Advanced usage

If you are familiar with programmation or Docker containers, you may want
to customize the Mozart 1.4.0 container.
This section provides more advanced documentation to do so.

### Python script for container deployment

The executable
will actually run a Python script ([build.py](build.py))
that builds and deploys the container with the default command line options.
If you want to customize those options, you can directly run the script from the
command line.
To do this, clone or download this repository,
then run the following command in the repository root directory:
```shell
python build.py [-d SHARED_DIR_HOST] [-n INSTANCE_NAME] [-p PORT_MAPPING]
```
(or `python3`, `py`, ... instead of `python` to suit your python command)

The `-d` option allows to provide the path of a host directory
that will be shared with the container.
This directory can be used, for example, to store Oz source code files.
Inside the container, this directory will be located in `/root/DIR_BASENAME`,
where DIR_BASENAME is the basename of the shared host directory.
If the argument is not specified, the default host directory to be shared is
`C:\Users\USER\oz-files`, where USER is the name of the current user,
which will be created if not present.
NB : the files you create, modify and save on the container directory will be saved in the host directory too.

The `-n` option allows to provide the name to give to the container instance.
Please note that two running instances can not have the same name.
If the argument is not specified, the default value is `mozart-1.4.0_n`,
where `n` is the index of this instance, starting from 0.

The `-p` option allows to provide the port mappings between the host ports
and the container ports, with the syntax `host_port:container_port`.
More precisely, this means that, for every mapping,
the port `container_port` inside the container can be accessed from
the host port `host_port`.
To provide multiple mappings, simply provide this option multiple times.
Please note that a same host port cannot be mapped to multiple container instances.
If this option is not specified, the default port mappings are
the following:
- {9000+`index`}:9000
- {33000+`index`}:33000
- {34000+`index`}:34000
- {35000+`index`}:35000
- {36000+`index`}:36000

where `index` is the index of this instance among all the running instances,
starting from 0.


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
nohup oz &> /dev/null &
```

### Rebuild the executable

The application executable was build with PyInstaller, a Python tool to build
executable files from Python source code.
If you want to rebuild the executable from the source code, please follow those
instructions:
- Install Python, version 3.5 or higher: https://www.python.org/downloads/
- Install PyInstaller: https://www.pyinstaller.org/
- Clone or download this repository.
- Run, in the root directory of this repository, the following command in a shell:
```shell
pyinstaller --clean --onefile --add-data "resources\config.xlaunch;." -i resources\oz.ico -n mozart-1.4.0-win build.py
```

The executable will be located in `dist\mozart-1.4.0-win.exe`.


## Supported platforms

- Windows 10

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
With the default options, as indicated before, 5 ports are already published.
