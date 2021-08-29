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

# First argument is the host directory containing the Oz files
OZ_DIR_HOST=$1
OZ_DIR_COTAINER="/root/$(basename $OZ_DIR_HOST)"
echo "Oz files are in $OZ_DIR_HOST on the host."
echo "They will be placed in $OZ_DIR_COTAINER inside the container."

# Second argument is the name of the container instance
INSTANCE=$2
echo "The container instance will be named '$INSTANCE'."

# Remaining arguments are the port mappings host_port:container_port
PUBLISHED_PORTS=""
i=0
for PORT in "$@"
do
    if [[ $i -gt 1 ]]
    then
        PUBLISHED_PORTS="$PUBLISHED_PORTS-p $PORT "
    fi
    ((i=i+1))
done


##########################################
# STEP 4: Build and run Docker container #
##########################################

IP=$(ipconfig getifaddr en0)  # Host IP address

# Load container image if not loaded
var=$(docker images)
if [[ $var != *"mozart-1.4.0"* ]] || [[ $var != *"centos"* ]]
then
    echo "Loading docker images, please wait..."
fi
if [[ $var != *"centos"* ]]
then
    docker load < images/centos.tar
fi
if [[ $var != *"mozart-1.4.0"* ]]
then
    docker load < images/mozart-1.4.0.tar
fi
# Run an instance of the container
docker run --rm --name $INSTANCE -it \
    $PUBLISHED_PORTS \
    --volume="$OZ_DIR_HOST:$OZ_DIR_COTAINER:rw" \
    -e DISPLAY=$IP:0 \
    $IMAGE
