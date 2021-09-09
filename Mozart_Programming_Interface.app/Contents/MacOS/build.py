'''
Python script to build and deploy an instance of the Mozart 1.4.0 container,
on a MacOS operating system.

Usage: python build.py OPTIONS
Options (optional):
    * -h, --help
        Show the help message.
    * -d SHARED_DIR, --directory SHARED_DIR
        Indicate the host directory that will be shared with the container, to store (for example) Oz source code files.
        Default is ~/Desktop/oz-files.
    * -n NAME, --name Name
        Indicate the name of the container instance that will be deployed.
        Default is `mozart-1.4.0_n`, where `n` is the index of this instance among the running instances (starting from 0).
    * -p PORT, --port PORT
        Indicate a port mapping between a host port and a container port.
        Syntax: host_port:container_port
        A mapping means that the container port is accessible from the host port.
        To define multiple mappings, simple provide this option multiple times.
        Default mappings are 9000:9000, 33000:33000, 34000:34000, 35000:35000, 36000:36000.

Authors: DEFRERE Sacha, DE KEERSMAEKER Francois, KUPERBLUM Jeremie
'''

import sys, os, subprocess, argparse

# Description of the script, used by the argument parser
description = "Build and deploy the Mozart 1.4.0 container."
# User home directory path
user_path = os.path.expanduser("~")


#############
# FUNCTIONS #
#############

def check_and_install_package(name, install_cmd=None):
    '''
    Check if a package is installed, and install it if not.
    :param name: package name
    :param install_cmd: command used to install the package
    :return: True if package was already installed or was successfully installed,
             False otherwise
    '''
    print(f"Checking if {name} is installed.")
    # Command to check if the package is installed
    command = f"which -s {name} &> /dev/null"
    # Run command and get return code
    return_code = subprocess.run(command, shell=True).returncode
    if return_code == 0:
        # Return code was 0, package is already installed
        print(f"{name} is already installed.")
        return True
    else:
        # Return code was not 0, package is not installed.
        # Install the package
        print(f"Installing {name}.")
        if not install_cmd:
            # Default install command with brew
            install_cmd = f"brew install {name}"
        subprocess.run(install_cmd, shell=True)
        # Check if installation was successful
        # Command to check if the package is installed
        command = f"which -s {name} &> /dev/null"
        # Run command and get return code
        return_code = subprocess.run(command, shell=True).returncode
        if return_code == 0:
            # Return code was 0, installation was successful
            print(f"Successfully installed {name}.")
            return True
        else:
            # Return code was not 0, installation failed
            print(f"Installation of {name} failed.")
            return False


def get_ip(ifconfig_output):
    '''
    Retrieves an IPv4 address from an `ifconfig` output,
    following the order of preference for the addresses first number:
    192, then 130, then 172, then the first IP addres found if the first
    number is not one of these.
    Returns `None` if no IPv4 address was found.
    '''
    lst_of_ip = []
    for line in ifconfig_output.strip().split("\n"):
        if "inet" in line:
            # Found the line with the IPv4 address, extract address
            ip = line.split(" ")[1].strip()
            lst_of_ip.append(ip)
    for ip in lst_of_ip :
        if "192" in ip[:3]:  # IPs that start with "192" are the preferred ones
            return ip
    for ip in lst_of_ip :
        if "130" in ip[:3]:  # Then IPs that start with "130"
            return ip
    for ip in lst_of_ip :
        if "172" in ip[:3]:  # Then IPs that start with "172"
            return ip
    # No IP starting with "192", "130" or "172" was found
    try :
        # Return the first IPv4 address found
        return lst_of_ip[0]
    except IndexError:
        # No IPv4 address was found, return None
        return None


##########################
# COMMAND LINE ARGUMENTS #
##########################

# Default values for optional command line arguments

# Shared host drectory, default is ~/oz-files
shared_dir_host = f"{user_path}/oz-files"

# Name of the container instance, based on the number of already running instances:
# "mozart-1.4.0_n", where n is the index of the instance among the running instances
image = "fdekeers/mozart-1.4.0"  # Name of the container image
instance = "mozart-1.4.0_"  # Base name of the instance, without the index
command = f"docker ps -aq -f ancestor={image}"  # Docker command to get the list of already running instances of the image mozart-1.4.0
output = subprocess.run(command, shell=True, stdout=subprocess.PIPE).stdout.decode("utf-8")  # Run command and retrieve output
index = output.count("\n")  # Count the number of lines, which is equal to the number of instances running
instance += str(index)  # Append the index number to the instance name

# Default port mappings host_port:container_port
# Those mapping are used for Windows
# such that the container ports can be accessed from the host IP address.
# The default host ports are incremented for every new container instance,
# but the container ports are the same for every container instance.
port_mappings = [f"{9000+index}:9000",
                 f"{33000+index}:33000",
                 f"{34000+index}:34000",
                 f"{35000+index}:35000",
                 f"{36000+index}:36000"]

# Command line argument parsing, using an ArgumentParser object

# Initialize argument parser with the description of the script
parser = argparse.ArgumentParser(description=description)

# First argument: host shared directory, option `-d` or `--directory`
help = """Host directory that will be shared with the container.
Default is ~/Desktop/oz-files."""
parser.add_argument("-d", "--directory", type=str,
                    help=help)

# Second argument: container instance name, option `-n` or `--name`
help = """Name of the container instance.
Default is 'mozart_1.4.0_n', where n is the index of this instance."""
parser.add_argument("-n", "--name", type=str,
                    help=help)

# Third argument: Port mappings between host and container, option `-p` or `--port`
help = """Port mapping host_port:container_port.
For multiple mappings, use this option multiple times.
Default mappings are 9000:9000, 33000:33000, 34000:34000, 35000:35000, 36000:36000."""
parser.add_argument("-p", "--port", type=str, action="append",
                    help=help)

# Parse arguments, and replace their default value if they are present
args = parser.parse_args()
shared_dir_host = os.path.abspath(args.directory) if args.directory else shared_dir_host
instance = args.name if args.name else instance
port_mappings = args.port if args.port else port_mappings

# Set container shared directory path from host shared directory
shared_dir_container = f"/root/{os.path.basename(shared_dir_host)}"

# Create shared host directory if it does not exist
if not os.path.exists(shared_dir_host):
    # Directory does not exist, create it
    os.makedirs(shared_dir_host)

# Format port mappings for the Docker `run` command:
# build a string with `-p` before each port mapping
# (-p host_1:container_1 -p host_2:container_2 -p host_3:container_3 ...)
ports_string = ""
for port in port_mappings:
    ports_string += f"-p {port} "


#############################
# INSTALL REQUIRED PACKAGES #
#############################

# Homebrew, a package manager, to ease the installation of upcoming packages
command = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
# Install Homebrew if not already installed, and check installation
install_ok = check_and_install_package("brew", command)
if not install_ok:
    # Installation failed, exit
    exit(-1)

# socat, a tool to redirect sockets
# Install socat if not already installed, and check installation
install_ok = check_and_install_package("socat")
if not install_ok:
    # Installation failed, exit
    exit(-1)

# XQuartz, a X11 server for MacOS
# Install XQuartz if not already installed, and check installation
install_ok = check_and_install_package("xquartz")
if not install_ok:
    # Installation failed, exit
    exit(-1)

# wmctrl, a tool to interact with GUI windows
# Install wmctrl if not already installed, and check installation
install_ok = check_and_install_package("wmctrl")
if not install_ok:
    # Installation failed, exit
    exit(-1)


#################################
# SETUP X11 SERVER WITH XQUARTZ #
#################################

# Redirect socket to the X11 server
command = "socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\\\"$DISPLAY\\\""
subprocess.Popen(command, shell=True)

# Start XQuartz
command = "open -a Xquartz"
subprocess.run(command, shell=True)

# Get host IP addresses with ifconfig
command = "ifconfig | grep -w inet"
output = subprocess.run(command, shell=True, stdout=subprocess.PIPE).stdout.decode("utf-8")
# Get a host IPv4 address from ifconfig output
ip = get_ip(output)
if ip is None:
    # No IPv4 address was found, exit
    sys.stderr.write("No IPv4 address was found to connect to XQuartz.\n")
    sys.stderr.write("Please check network settings.\n")
    exit(-1)
print(f"Connecting to XQuartz with IP {ip}")
# Add IP address to the addresses accepted by XQuartz
command = f"xhost +{ip}"
subprocess.run(command, shell=True)


##############################################
# BUILD AND RUN AN INSTANCE OF THE CONTAINER #
##############################################

# Pull container image from Docker DockerHub
print("Pulling container image from Docker Hub, please wait...")
command = f"docker pull {image}"
subprocess.run(command, shell=True)

# Background script to make the Mozart window visible when started
# This script will toggle fullscreen on and off on the Mozart window.
script = """#!/bin/zsh
number=$(wmctrl -l | wc -l)
while [[ $(wmctrl -l | wc -l) -eq $number ]] do
continue
done
win=$(wmctrl -l | sed -n $((number+1))p | cut -d' ' -f4)
wmctrl -r $win -b add,fullscreen
wmctrl -r $win -b remove,fullscreen
"""
# Write script into a temporary file
with open(f"{user_path}/script_temp.sh", "w") as file:
    file.writelines(script)
# Make the script file executable
subprocess.run(f"chmod +x {user_path}/script_temp.sh", shell=True)
# Run the script in background
subprocess.Popen(f"{user_path}/script_temp.sh", shell=True)

# Indicate argument configuration to the user
print(f"Running instance {instance} of the container.")
print(f"The shared host directory is {shared_dir_host}.")
print(f"Its path inside the container is {shared_dir_container}.")
print(f"The port mappings host_port:container_port are the following:\n{port_mappings}.")

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
command = f'docker run --rm --name {instance} -it ' \
          f'{ports_string} ' \
          f'--volume="{shared_dir_host}:{shared_dir_container}:rw" ' \
          f'-e DISPLAY={ip}:0 ' \
          f'{image}'
subprocess.run(command, shell=True)


############
# CLEANING #
############

# Stop X11 server if all the instances of the container have been stopped
# Docker command to list all running instances of the fdekeers/mozart-1.4.0 image
command = f"docker ps -aq -f ancestor={image}"
output = subprocess.run(command, shell=True, stdout=subprocess.PIPE).stdout
if not output:
    # Output of command is empty, all the instances have been stopped
    # Remove the temporary script used to make the Mozart window visible when started
    os.remove(f"{user_path}/script_temp.sh")
    # Remove IP address from the addresses accepted by XQuartz
    command = f"xhost -{ip}"
    subprocess.run(command, shell=True)
    # Stop XQuartz
    command = "osascript -e 'quit app \"XQuartz\"'"
    subprocess.run(command, shell=True)
    # Stop socat
    command = "killall socat"
    subprocess.run(command, shell=True)