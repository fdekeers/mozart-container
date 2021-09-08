#!/bin/python3

'''
Python script to build and deploy an instance of the Mozart 1.4.0 container,
on a Linux host.
Warning: The user running this script must have `sudo` permissions.

Usage: python build.py OPTIONS
Options (optional):
    * -h, --help
        Show the help message.
    * -d SHARED_DIR, --directory SHARED_DIR
        Indicate the host directory that will be shared with the container, to store (for example) Oz source code files.
        Default is ~/oz-files.
    * -n NAME, --name Name
        Indicate the name of the container instance that will be deployed.
        Default is `mozart-1.4.0_n`, where `n` is the index of this instance among the running instances (starting from 0).

Author: Francois De Keersmaeker
'''

import os, subprocess, argparse

# Description of the script, used by the argument parser
description = "Build and deploy the Mozart 1.4.0 container on Linux."
# User home directory path
user_path = os.path.expanduser("~")


##########################
# COMMAND LINE ARGUMENTS #
##########################

# Default values for command line arguments

# Shared host directory, default is ~/oz-files
shared_dir_host = f"{user_path}/oz-files"

# Name of the container instance, based on the number of already running instances:
# "mozart-1.4.0_n", where n is the index of the instance among the running instances
image = "fdekeers/mozart-1.4.0"  # Name of the container image
instance = "mozart-1.4.0_"  # Base name of the instance, without the index
command = f"sudo docker ps -aq -f ancestor={image}"  # Docker command to get the list of already running instances of the image mozart-1.4.0
output = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE).communicate()[0].decode("utf-8")  # Run command and retrieve output
lines = output.count("\n")  # Count the number of lines, which is equal to the number of instances running
instance += str(lines)  # Append the index number to the instance name

# Command line argument parsing, using an ArgumentParser object

# Initialize argument parser with the description of the script
parser = argparse.ArgumentParser(description=description)

# First argument: host shared directory, option `-d` or `--directory`
help = """Host directory that will be shared with the container.
Default is ./oz-files."""
parser.add_argument("-d", "--directory", type=str,
                    help=help)

# Second argument: container instance name, option `-n` or `--name`
help = """Name of the container instance.
Default is 'mozart_1.4.0_n', where n is the index of this instance."""
parser.add_argument("-n", "--name", type=str,
                    help=help)

# Parse arguments, and replace their default value if they are present
args = parser.parse_args()
shared_dir_host = os.path.abspath(args.directory) if args.directory else shared_dir_host
instance = args.name if args.name else instance

# Set container shared directory path from host shared directory
shared_dir_container = f"/root/{os.path.basename(shared_dir_host)}"

# Create shared host directory if it does not exist
if not os.path.exists(shared_dir_host):
    # Directory does not exist, create it
    os.makedirs(shared_dir_host)


####################################
# RUN AN INSTANCE OF THE CONTAINER #
####################################

# Disable host access control for X11, to allow GUI applications from containers
command = "xhost +local:*"
subprocess.run(command, shell=True)

# Start Docker daemon
print("Starting Docker daemon.")
command = "sudo systemctl start docker"
subprocess.run(command, shell=True)

# Pull container image from Docker Hub
print("Pulling container image from Docker Hub, please wait...")
command = f"sudo docker pull {image}"
subprocess.run(command, shell=True)

# Indicate argument configuration to the user
print(f"Running instance {instance} of the container.")
print(f"The shared host directory is {shared_dir_host}.")
print(f"Its path inside the container is {shared_dir_container}.")

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
command = f'''sudo docker run --rm --name {instance} -it \\
--volume="{shared_dir_host}:{shared_dir_container}:rw" \\
--volume="{user_path}/.Xauthority:/root/.Xauthority:rw" \\
--env="DISPLAY" \\
--net=host \\
{image}'''
subprocess.run(command, shell=True)


############
# CLEANING #
############

# Re-enable host access control for X11, if all the container instances are stopped,
# to prevent unwanted clients to connect.

# Get list of running instances of the image fdekeers/mozart-1.4.0
command = f"sudo docker ps -aq -f ancestor={image}"
output = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE).communicate()[0].decode("utf-8")

# Check if the above list is empty
if not output:
    # List is empty, re-enable host access control
    command = "xhost local:*"
    subprocess.run(command, shell=True)
