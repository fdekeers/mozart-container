#!/bin/bash

# Bash script to build and deploy the Mozart 1.4 Docker container.
#
# Author: François De Keersmaeker

# Variables
CONTAINER="mozart-1.4"  # Name of the container
OZ_DIR_HOST="$(pwd)/oz-files"  # Directory containing the Oz files on the host
OZ_DIR_COTAINER="/home/user/oz-files"  # Directory containing the Oz files inside the container

# First argument is the directory containing the Oz files
if [[ $# -gt 0 ]]
then
    OZ_DIR_HOST="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
    OZ_DIR_COTAINER="/home/user/$(basename $OZ_DIR_HOST)"
fi
echo "Oz files are in $OZ_DIR_HOST on the host."
echo "They will be placed in $OZ_DIR_COTAINER inside the container."

# Disable host access control, to allow GUI applications from containers
xhost +

# Build and run the container
echo "Please wait while the container is built..."
sudo docker build -q -t $CONTAINER .
sudo docker run --rm --name $CONTAINER -it \
    --volume="$OZ_DIR_HOST:$OZ_DIR_COTAINER" \
    --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
    --env="DISPLAY" \
    --net=host \
    $CONTAINER
