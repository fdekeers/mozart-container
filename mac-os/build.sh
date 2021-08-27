#!/bin/zsh

# Zsh script to build and deploy the Mozart 1.4.0 Docker container on MacOS.
# Inspired from https://cntnr.io/running-guis-with-docker-on-mac-os-x-a14df6a76efc
# to run a GUI application with Docker on MacOS.
#
# Author: Francois De Keersmaeker


##########################################
# STEP 1: Install the X11 server XQuartz #
##########################################

# Install Homebrew, the package manager
echo "Installing brew, a package manager."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Install socat, a tool to redirect sockets
echo "Installing socat, a tool to redirect sockets."
brew install socat
# Install XQuartz, the X11 server for MacOS
echo "Installing XQuartz, a X11 to allow GUI applications inside Docker containers."
brew install xquartz
# Prompt the user to log out and log back in such that everything is setup
echo "Please log out and log back in to your MacOS session to confirm installation."


################################
# STEP 2: Setup the X11 server #
################################

# Redirect socket to the X11 server
socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
# Start XQuartz
open -a Xquartz
# Prompt the user to check both cases in the "Security" tab of XQuartz preferences
echo "Please go to the preferences of XQuartz (top left corner of the screen),"
echo "'Security' tab, and check both checkboxes."


######################################
# STEP 3: Get command line arguments #
######################################

IMAGE="mozart-1.4.0"  # Name of the container
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


##########################################
# STEP 4: Build and run Docker container #
##########################################

IP=$(ipconfig getifaddr en0)  # Host IP address

# Build container image
echo "Building container, please wait..."
docker build -t $IMAGE .
# Run an instance of the container
# The published ports can be modified here
PUBLISHED-PORTS="-p 33000:33000 -p 34000:34000 -p 35000:35000 -p 36000:36000 -p 37000:37000"
docker run --rm --name $INSTANCE -it \
    $PUBLISHED_PORTS \
    --volume="$OZ_DIR_HOST:$OZ_DIR_COTAINER:rw" \
    -e DISPLAY=$IP:0 \
    $IMAGE
