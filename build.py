'''
Python script to build and deploy an instance of the Mozart 1.4.0 container
on Windows platforms.

Usage: python build.py OPTIONS
Options (optional):
    * -h, --help
        Show the help message.
    * -d SHARED_DIR, --directory SHARED_DIR
        Indicate the host directory that will be shared with the container, to store (for example) Oz source code files.
        Default is .\oz-files.
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

import os, platform, subprocess, argparse, time

# Description of the script, used by the argument parser
description = "Build and deploy the Mozart 1.4.0 container on Windows platforms."
# Parent directory of this script
parent_dir = os.path.dirname(os.path.abspath(__file__))


#############
# Functions #
#############

def compute_md5(filename):
    '''
    Computes the MD5 hash of a file,
    per chunks of 8 kB to not saturate memory.
    From https://stackoverflow.com/questions/16874598/how-do-i-calculate-the-md5-checksum-of-a-file-in-python
    '''
    chunk_size = 8192
    with open(filename, "rb") as file:
        hash = hashlib.md5()
        chunk = file.read(chunk_size)
        while chunk:
            hash.update(chunk)
            chunk = file.read(chunk_size)
        return hash.hexdigest()


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
    192, then 130, then 172, then the first IP addres found if the first
    number is not one of these.
    Returns `None` if no IPv4 address was found.
    '''
    with open(filename, "r") as file:
        lst_of_ip = []
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
        return lst_of_ip[0] # if it doesn't exist an IP that begin with "192" or "130" or "172", we return the first IP found
    return None


##########################
# COMMAND LINE ARGUMENTS #
##########################

# Default values for optional command line arguments

# Shared host drectory, default is .\oz-files
shared_dir_host = f"{parent_dir}\\oz-files"

# Name of the container instance, based on the number of already running instances:
# "mozart-1.4.0_n", where n is the index of the instance among the running instances
image = "fdekeers/mozart-1.4.0"  # Name of the container image
instance = "mozart-1.4.0_"  # Base name of the instance, without the index
command = f"docker ps -aq -f ancestor={image}"  # Docker command to get the list of already running instances of the image mozart-1.4.0
output = subprocess.run(command, shell=True, stdout=subprocess.PIPE).stdout.decode("utf-8")  # Run command and retrieve output
lines = output.count("\n")  # Count the number of lines, which is equal to the number of instances running
instance += str(lines)  # Append the index number to the instance name
print(instance)

# Default port mappings host_port:container_port
# Those mapping are used for Windows
# such that the container ports can be accessed from the host IP address.
port_mappings = ["9000:9000", "33000:33000", "34000:34000", "35000:35000", "36000:36000"]

# Command line argument parsing, using an ArgumentParser object

# Initialize argument parser with the description of the script
parser = argparse.ArgumentParser(description=description)

# First argument: host shared directory, option `-d` or `--directory`
help = """Host directory that will be shared with the container.
Default is .\oz-files."""
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


#############################################
# DOWNLOAD AND INSTALL A WINDOWS X11 SERVER #
#############################################

print("For this container to work properly, you need to have VcXsrv installed.")
print("VcXsrv is a X11 server for Windows, which allows GUI application that allows GUI applications inside Docker containers.")
# Check if VcXsrv is already installed
# Warning: check only in C:\Program Files
print("Checking if VcXsrv is already installed, please wait...")
vcxsrv_exec = find_file("xlaunch.exe")
if vcxsrv_exec is None:  # VcXsrv is not installed
    print("VcXsrv is not installed.")
    # VcXsrv SourceForge download link
    vcxsrv_url = "https://downloads.sourceforge.net/project/vcxsrv/vcxsrv/1.20.9.0/vcxsrv-64.1.20.9.0.installer.exe"
    vcxsrv_file = "vcxsrv-64.1.20.9.0.installer.exe"  # Filename of the installer
    vcxsrv_md5 = "3fe9fbdcc47b934cdd8e0c01f9008125"  # MD5 hash of the installer
    # Download VcXsrv installer, with a PowerShell command
    print("Downloading VcXsrv installer.")
    command = f'powershell.exe -Command "Start-BitsTransfer -Source {vcxsrv_url}"'
    subprocess.run(command, shell=True)
    # Check MD5 hash of downloaded file
    if compute_md5(vcxsrv_file) != vcxsrv_md5:
        # MD5 not identical, exit
        sys.stderr.write("MD5 verification failed !")
        sys.stderr.write("Please run the script again to retry.")
        # Remove installer file
        os.remove(vcxsrv_file)
        exit(-1)
    # MD5 identical, proceed
    print("MD5 of downloded file verified.")
    # Install VcXsrv by running installer
    print("Installing VcXsrv.")
    print("Please keep all default settings, mostly the installation directory that should be C:\\Program Files.")
    subprocess.run(vcxsrv_file, shell=True)
    # Remove installer file
    os.remove(vcxsrv_file)
    # Find VcXsrv executable
    # Warning: only check in C:\Program Files, VcXsrv should be installed there
    print("Searching for VcXsrv executable, please wait...")
    vcxsrv_exec = find_file("xlaunch.exe")
else:  # VcXsrv is already installed
    print("VcXsrv is already installed.")


################################
# START X11 SERVER WITH VCXSRV #
################################

# Check if VcXsrv executable has been found in C:\Program Files
if vcxsrv_exec is None:
    # Executable not found, exit
    sys.stderr.write("Could not find VcXsrv executable.\n")
    sys.stderr.write("Please check that the VcXsrv installation was correctly done in the directory C:\\Program Files\\VcXsrv.\n")
    exit(-1)

# Launch VcXsrv executable with configuration file, if it has not been already started
# Windows CMD command to check if there is a running process called vcxsrv.exe
command = 'tasklist /fi "ImageName eq vcxsrv.exe" /fo csv 2>NUL | find /I "vcxsrv.exe" > NUL'
if subprocess.run(command, shell=True).returncode != 0:
    # VcXsrv has not been started yet
    print("Starting X11 server.")
    # Start VcXsrv with configuration file, to allow all clients to connect
    command = f'"{vcxsrv_exec}" -run "{parent_dir}\\resources\\config.xlaunch"'
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
print(f"Your local IPv4 address is {ip}")
# Remove temporary ipconfig results file
os.remove(filename)
# Check if IP was found
if ip is None:
    # IP was not found, exit
    sys.stderr.write("Could not find any host IPv4 address.\n")
    exit(-1)
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
