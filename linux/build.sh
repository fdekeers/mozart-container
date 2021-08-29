#!/bin/bash

# Bash script to build and deploy the Mozart 1.4.0 Docker container on Linux.
#
# Author: Francois De Keersmaeker

# Variables
IMAGE="mozart-1.4.0"  # Name of the container image
INSTANCE=$IMAGE  # Name of the container instance
OZ_DIR_HOST="$(pwd)/oz-files"  # Directory containing the Oz files on the host
OZ_DIR_COTAINER="/root/oz-files"  # Directory containing the Oz files inside the container

# Command line arguments
# First argument is the host directory containing the Oz files
OZ_DIR_HOST=$1
OZ_DIR_COTAINER="/root/$(basename $OZ_DIR_HOST)"
echo "Oz files are in $OZ_DIR_HOST on the host."
echo "They will be placed in $OZ_DIR_COTAINER inside the container."

# Second argument is the name of the container instance
INSTANCE=$2
echo "The container instance will be named '$INSTANCE'."

# Remaining arguments are the port mappings, useless in the case of Linux,
# since host networking is used.

# Disable host access control for X11, to allow GUI applications from containers
xhost +local:*

# Load container images
echo "Starting docker daemon."
sudo systemctl start docker
# Checking if images are already loaded, load them if not
var=$(sudo docker images)
if [[ $var != *"mozart-1.4.0"* ]] || [[ $var != *"centos"* ]]
then
    echo "Loading docker images, please wait..."
fi
if [[ $var != *"centos"* ]]
then
    sudo docker load < images/centos.tar
fi
if [[ $var != *"mozart-1.4.0"* ]]
then
    sudo docker load < images/mozart-1.4.0.tar
fi
# Run the container
echo "Running the container."
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
