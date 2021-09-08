#!/bin/zsh

# Zsh script to build and deploy the Mozart 1.4.0 Docker container on MacOS.
# Inspired from https://cntnr.io/running-guis-with-docker-on-mac-os-x-a14df6a76efc
# to run a GUI application with Docker on MacOS.
#
# Usage, from the parent directory:
#     mac-os/build.sh SHARED_DIR_HOST INSTANCE_NAME PORT_MAPPINGS
#         SHARED_DIR_HOST is the host directory that will be shared with the container
#         INSTANCE_NAME is the name that will be given to the container instance
#         PORT_MAPPINGS is the mappings between host ports and container ports,
#             with the syntax "host_port:container_port"
#
# Remark: This script should not be used directly,it should only be called by
# the general `build.py` python script in the parent directory.
# Please use the `build.py` python script to deploy instances of the mozart-1.4.0 container.
#
# Author: Francois De Keersmaeker


##########################################
# STEP 1: Install the X11 server XQuartz #
##########################################

# Install Homebrew, the package manager, to ease the installation of following tools
echo "Checking if Homebrew, the package manager, is installed."
if which -s brew &> /dev/null
then
    # Homebrew is already installed
    echo "Homebrew is already installed."
else
    echo "Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install socat, a tool to redirect sockets
echo "Checking if socat, a tool to redirect sockets, is installed."
if which -s socat &> /dev/null
then
    # socat is already installed
    echo "socat is already installed."
else
    echo "Installing socat".
    brew install socat
fi

# Install XQuartz, the X11 server for MacOS
echo "Installing XQuartz, a X11 to allow GUI applications inside Docker containers."
if which -s xquartz &> /dev/null
then
    # XQuartz is already installed
    echo "XQuartz is already installed."
else
    echo "Installing XQuartz."
    brew install xquartz
fi

# Prompt the user to log out and log back in such that everything is setup
#echo "Please log out and log back in to your MacOS session to confirm installation."

# Install xdotool, to move the XQuartz windows that appear offscreen
echo "Installing xdotool, to allow moving the XQuartz windows that appear offscreen (mainly when using more than one monitor)."
if which -s xdotool &> /dev/null
then
    # xdotool is already installed
    echo "xdotool is already installed."
else
    echo "Installing xdotool."
    brew install xdotool
fi


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
read -s -k $'?Press any key when this is done.\n'


######################################
# STEP 3: Get command line arguments #
######################################

IMAGE="fdekeers/mozart-1.4.0"  # Name of the container image

# First argument is the shared host directory
OZ_DIR_HOST=$1
# The shared directory path inside the container is based on the basename of the host shared directory
OZ_DIR_COTAINER="/root/$(basename $OZ_DIR_HOST)"
echo "Oz files are in $OZ_DIR_HOST on the host."
echo "They will be placed in $OZ_DIR_COTAINER inside the container."

# Second argument is the name of the container instance
INSTANCE=$2
echo "The container instance will be named '$INSTANCE'."

# Remaining arguments are the port mappings host_port:container_port
# They must be formatted before passing to the `docker run` command
PUBLISHED_PORTS=""
i=0
for PORT in "$@"
do
    if [[ $i -gt 1 ]]  # Port mappings start at argument #2
    then
        # Add `-p host_port:container_port` to the string representing all the port mappings
        PUBLISHED_PORTS="$PUBLISHED_PORTS-p $PORT "
    fi
    ((i=i+1))
done


##########################################
# STEP 4: Build and run Docker container #
##########################################

# Get host IP address, necessary for GUI application inside the container, and add it to the X11 allowed addresses
IP=$(ifconfig | grep -w inet | grep -v 127.0.0.1 | cut -d' ' -f2 | sed -n 1p)
echo "Connecting to XQuartz with IP $IP"
xhost +$IP

# Pull container image from DockerHub
echo "Pulling container image from DockerHub, please wait..."
docker pull $IMAGE

# Create function to replace correctly the emacs window
echo "sleep 3
pids=\$(xdotool search --class 'emacs')
for pid in \$pids; do
    xdotool windowmove \$pid 200 200
done
" > temp.sh && chmod +x temp.sh

# Run an instance of the container
# Options:
#     --rm -> container instance is removed when stopped
#     --name NAME -> set the container instance name
#     -i (interactive) -> keep STDIN open even if not attached
#     -t (tty) -> allocate a pseudo-TTY
#     -p HOST_PORT:CONTAINER_PORT -> port mappings between the host and the container.
#         The specified container ports can be accessed from the mapped host ports.
#     --volume="HOST_DIR:CONTAINER_DIR:MODE" -> share a directory between the host and the container,
#                                               with the specified access mode (rw for read-write)
#     -e -> set environmental variables
#         (here, set DISPLAY to the host IP address, to allow GUI applications inside the container)

bash ./test.sh &
docker run --rm --name $INSTANCE -it \
    $(echo "$PUBLISHED_PORTS") \
    --volume="$OZ_DIR_HOST:$OZ_DIR_COTAINER:rw" \
    -e DISPLAY=$IP:0 \
    $IMAGE

rm temp.sh
# Re-enable host access control for X11, if all the container instances are stopped,
# to prevent unwanted clients to connect.
# Check if the list of running instances of the image fdekeers/mozart-1.4.0 is empty
if [[ -z $(docker ps -aq -f ancestor=$IMAGE) ]]
then
    # List is empty, re-enable host access control
    xhost -$IP
    osascript -e 'quit app "XQuartz"'
    killall socat
fi
