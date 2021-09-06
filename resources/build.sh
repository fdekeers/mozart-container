#!/bin/bash

# Bash script to build and deploy the Mozart 1.4.0 Docker container on Linux.
#
# Usage, from the parent directory:
#     linux/build.sh SHARED_DIR_HOST INSTANCE_NAME
#         SHARED_DIR_HOST is the host directory that will be shared with the container
#         INSTANCE_NAME is the name that will be given to the container instance
#
# Remark: This script should not be used directly,it should only be called by
# the general `build.py` python script in the parent directory.
# Please use the `build.py` python script to deploy instances of the mozart-1.4.0 container.
#
# Author: Francois De Keersmaeker

# Creating Desktop launcher
echo "[Desktop Entry]
Version=1.0
Type=Application
Terminal=true
Exec=$HOME/Desktop/job/mozart-container/Mozart_Programming_Interface.sh
Name=Mozart_Programming_Interface
Icon=$HOME/Desktop/job/mozart-container/resources/icon.ico
Categories=Development;IDE;" > ~/.local/share/applications/Mozart_Programming_Interface.desktop

# Variables
IMAGE="fdekeers/mozart-1.4.0"  # Name of the container image
INSTANCE="mozart-1.4.0"  # Name of the container instance
SHARED_DIR_HOST="$(pwd)/oz-files"  # Host directory that will be shared with the container (default: ../oz-files)
SHARED_DIR_CONTAINER="/root/oz-files"  # Shared directory path inside the container (default: /root/oz-files)

# Command line arguments
# First argument is the shared host directory
SHARED_DIR_HOST=$1
# Update shared container directory with basename of the host directory
SHARED_DIR_CONTAINER="/root/$(basename $SHARED_DIR_HOST)"
echo "Oz files are in $SHARED_DIR_HOST on the host."
echo "They will be placed in $SHARED_DIR_CONTAINER inside the container."

# Second argument is the name of the container instance
INSTANCE=$2
echo "The container instance will be named '$INSTANCE'."

# Remaining arguments are the port mappings, useless in the case of Linux, since host networking is used.
# This means that the container shares the network stack with the host,
# and thus both share IP addresses and ports.

# Disable host access control for X11, to allow GUI applications from containers
xhost +local:*

# Start Docker daemon
echo "Starting docker daemon."
sudo systemctl start docker
# Pull container image from DockerHub
echo "Pulling container image from DockerHub, please wait..."
docker pull $IMAGE

# Run an instance of the container
# Options:
#     --rm -> container instance is removed when stopped
#     --name NAME -> set the container instance name
#     -i (interactive) -> keep STDIN open even if not attached
#     -t (tty) -> allocate a pseudo-TTY
#     --volume="HOST_DIR:CONTAINER_DIR:MODE" -> share a directory between the host and the container,
#                                               with the specified access mode (rw for read-write)
#     --env -> set environmental variables (here, "DISPLAY" to allow GUI applications inside the container)
#     --net -> set networking mode (here, host networking)
echo "Running the container."
sudo docker run --rm --name $INSTANCE -it \
    --volume="$SHARED_DIR_HOST:$SHARED_DIR_CONTAINER:rw" \
    --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
    --env="DISPLAY" \
    --net=host \
    $IMAGE

# Re-enable host access control for X11, if all the container instances are stopped,
# to prevent unwanted clients to connect.
# Check if the list of running instances of the image fdekeers/mozart-1.4.0 is empty
if [[ -z $(docker ps -aq -f ancestor=$IMAGE) ]]
then
    # List is empty, re-enable host access control
    xhost -local:*
fi
