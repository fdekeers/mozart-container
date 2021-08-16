#!/bin/bash

# Bash script to build and deploy the Mozart 1.4.0 Docker container.
#
# Author: François De Keersmaeker

# Name of the container
CONTAINER="mozart-1.4.0"

# Build and run the container
sudo docker build -t $CONTAINER .
sudo docker run --rm --name $CONTAINER -it $CONTAINER /bin/bash