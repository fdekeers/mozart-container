#!/bin/bash

# Bash script to build and deploy the Mozart 1.4.0 Docker container on Linux.
#
# Author: Francois De Keersmaeker

# Variables
IMAGE="mozart-1.4.0"  # Name of the container image
INSTANCE=$IMAGE  # Name of the container instance
OZ_DIR_HOST="$(pwd)/oz-files"  # Directory containing the Oz files on the host
OZ_DIR_COTAINER="/root/oz-files"  # Directory containing the Oz files inside the container

# First (optional) argument is the host directory containing the Oz files
if [[ $# -gt 0 ]]
then
    OZ_DIR_HOST="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
    OZ_DIR_COTAINER="/root/$(basename $OZ_DIR_HOST)"
fi
echo "Oz files are in $OZ_DIR_HOST on the host."
echo "They will be placed in $OZ_DIR_COTAINER inside the container."

# Second (optional) argument is the name of the container instance
if [[ $# -gt 1 ]]
then
    INSTANCE=$2
fi
echo "The container instance will be named '$INSTANCE'."

# Disable host access control for X11, to allow GUI applications from containers
xhost +local:*

# Build and run the container
echo "Starting docker daemon."
sudo systemctl start docker
echo "Building container, please wait..."
sudo docker build -t $IMAGE .
sudo docker run --rm --name $INSTANCE -it \
    --volume="$OZ_DIR_HOST:$OZ_DIR_COTAINER:rw" \
    --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
    --env="DISPLAY" \
    --net=host \
    $IMAGE

# Clean: re-enable host access control for X11, if all the containers are stopped
if [[ -z $(docker ps -aq -f ancestor=$IMAGE) ]]
then
    xhost -local:*
fi
