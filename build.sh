#!/bin/bash

# Bash script to build and deploy the Mozart 1.4.0 Docker container.
#
# Author: François De Keersmaeker

# Variables
CONTAINER="mozart-1.4.0"  # Name of the container

# Disable host access control, to allow GUI applications from containers
xhost +

# Build and run the container
sudo docker build -t $CONTAINER .
sudo docker run --rm --name $CONTAINER -it \
    --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
    --env="DISPLAY" \
    --net=host \
    $CONTAINER