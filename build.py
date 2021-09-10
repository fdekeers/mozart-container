'''
Python script to build and deploy an instance of the Mozart 1.4.0 container
on Windows platforms.

Usage: python build.py OPTIONS
Options (optional):
    * -h, --help
        Show the help message.
    * -d SHARED_DIR, --directory SHARED_DIR
        Indicate the host directory that will be shared with the container, to store (for example) Oz source code files.
        Default is C:\\Users\\USER\\oz-files.
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
description = "Build and deploy the Mozart 1.4.0 container on Windows platforms."
# User home directory path
user_path = os.path.expanduser("~")
# Parent directory of this script
parent_dir = os.path.dirname(os.path.abspath(__file__))


#############
# Functions #
#############

def find_file(filename):
    '''
    Searches for a file in `C:\Program Files`,
    and returns its path.
    Returns `None` if file was not found.
    From https://stackoverflow.com/questions/1724693/find-a-file-in-python
    '''
    for root, dirs, files in os.walk(r"C:\Program Files"):
        if filename in files:
            return os.path.join(root, filename)
    return None


def get_ip(filename):
    '''
    Retrieves an IPv4 address from an `ipconfig` file output,
    following the order of preference for the addresses first number:
    192, then 130, then 172, then the first IP address found if no address
    with those starting numbers exist.
    Returns `None` if no IPv4 address was found.
    '''
    lst_of_ip = []
    with open(filename, "r") as file:
        for line in file.readlines():
            if "IPv4" in line:
                # Found the line with the IPv4 address, extract address
                ip = line.split(":")[1].strip()
                ip = ip.partition("(")[0].strip()
                lst_of_ip.append(ip)
    for ip in lst_of_ip :
        if "192" in ip[:3]: # IPs that begin with "192" are the preferred ones
            return ip
    for ip in lst_of_ip :
        if "130" in ip[:3]:
            return ip
    for ip in lst_of_ip :
        if "172" in ip[:3]:
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

# Shared host drectory, default is C:\Users\USER\oz-files
shared_dir_host = f"{user_path}\\oz-files"

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
Default is C:\\Users\\USER\\oz-files."""
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


################################
# START X11 SERVER WITH VCXSRV #
################################

# VcXsrv is a Windows X11 server, that allows applications running in Docker
# containers to benefit from GUI capabilities.

# Find VcXsrv executable
# Warning: only check in C:\Program Files, VcXsrv should be installed there
print("Searching for VcXsrv executable, please wait...")
vcxsrv_exec = find_file("xlaunch.exe")
# Check if VcXsrv executable has been found in C:\Program Files
if vcxsrv_exec is None:
    # Executable not found, exit
    sys.stderr.write("Could not find VcXsrv executable.\n")
    sys.stderr.write("Please check that the VcXsrv installation was correctly done in the directory C:\\Program Files\\VcXsrv.\n")
    exit(-1)

# Launch VcXsrv executable, if it has not been already started
# Windows CMD command to check if there is a running process called vcxsrv.exe
command = 'tasklist /fi "ImageName eq vcxsrv.exe" /fo csv 2>NUL | find /I "vcxsrv.exe" > NUL'
if subprocess.run(command, shell=True).returncode != 0:
    # VcXsrv has not been started yet
    print("Starting X11 server.")
    # Directory where the VcXsrv configuration file is located,
    # depends on if the application is launched from source code or bundle
    bundle_dir = getattr(sys, "_MEIPASS", os.path.abspath(os.path.join(parent_dir, "resources")))
    config_path = os.path.abspath(os.path.join(bundle_dir, "config.xlaunch"))
    # Start VcXsrv with configuration file, to allow all clients to connect
    command = f'"{vcxsrv_exec}" -run "{config_path}"'
    subprocess.run(command, shell=True)


#########################################################
# FIND A HOST IPV4 ADDRESS TO CONNECT TO THE X11 SERVER #
#########################################################

# The `ipconfig` tool will be used, that lists IP addresses
filename = ".ipconfig"  # Temporary file to write the `ipconfig` results to
command = f"ipconfig /all > {filename}"  # `ipconfig` command
subprocess.run(command, shell=True)
# Get IPv4 address from file
ip = get_ip(filename)
# Remove temporary ipconfig results file
os.remove(filename)
# Check if IP was found
if ip is None:
    # IP was not found, exit
    sys.stderr.write("Could not find any host IPv4 address.\n")
    exit(-1)
print(f"Connecting to VcXsrv with IP {ip}")
# Add port to address, which will be used for GUI applications inside the container
ip = f"{ip}:0"


##############################################
# BUILD AND RUN AN INSTANCE OF THE CONTAINER #
##############################################

# Pull container image from Docker Hub
print("Pulling container image from DockerHub, please wait...")
command = f"docker pull {image}"
subprocess.run(command, shell=True)

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
          f'-e DISPLAY={ip} ' \
          f'{image}'
subprocess.run(command, shell=True)


############
# CLEANING #
############

# Stop X11 server, if all the instances of the container have been stopped

# Docker command to list all running instances of the fdekeers/mozart-1.4.0 image
command = f"docker ps -aq -f ancestor={image}"
output = subprocess.run(command, shell=True, stdout=subprocess.PIPE).stdout
if not output:
    # Output of command is empty, all the instances have been stopped
    print("Stopping X11 server.")
    # Command to kill the vcxsrv.exe process
    command = "taskkill /f /im vcxsrv.exe"
    subprocess.run(command, shell=True)
