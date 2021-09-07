'''
Python script to build and deploy the Mozart 1.4.0 Docker container on Windows.

Usage, from the parent directory:
    python windows/build.py SHARED_DIR_HOST INSTANCE_NAME PORT_MAPPINGS
        SHARED_DIR_HOST is the host directory that will be shared with the container
        INSTANCE_NAME is the name that will be given to the container instance
        PORT_MAPPINGS is the mappings between host ports and container ports,
            with the syntax "host_port:container_port"

Remark: This script should not be used directly,it should only be called by
the general `build.py` python script in the parent directory.
Please use the `build.py` python script to deploy instances of the mozart-1.4.0 container.

Author: Francois De Keersmaeker
'''

import os, sys, subprocess, hashlib


#############
# Functions #
#############

def compute_md5(filename):
    '''
    Computes the MD5 hash of a file,
    per chunks of 8 kB.
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
    Retrieves any IPv4 address from an `ipconfig` file output.
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
            if "192" in ip[:3]: # IP that begin with "192" are the preferred one
                return ip
        for ip in lst_of_ip :
            if "130" in ip[:3]:
                return ip
        for ip in lst_of_ip :
            if "172" in ip[:3]:
                return ip
        return lst_of_ip[0] # if it doesn't exist an IP that begin with "192" or "130" or "172", we return the first IP found
    return None


#######################################
# STEP 1: Download and install VcXsrv #
#######################################

print("For this container to work correctly, you need to have VcXsrv installed.")
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


########################################
# STEP 2: Start X11 server with VcXsrv #
########################################

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
    command = f'"{vcxsrv_exec}" -run windows\\config.xlaunch'
    subprocess.run(command, shell=True)


#################################################################
# STEP 3: Find a host IPv4 address to connect to the X11 server #
#################################################################

# The `ipconfig` tool will be used, that lists IP addresses
filename = ".ipconfig"  # File to write the `ipconfig` results to
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


######################################
# STEP 4: Get command line arguments #
######################################

# First argument: path of shared directory on the host
shared_dir_host = sys.argv[1]
# Container shared directory path is based on the basename of the shared host directory
shared_dir_container = f"/root/{os.path.basename(shared_dir_host)}"
print(f"The path of the host shared directory is {shared_dir_host}.")
print(f"It will be placed in {shared_dir_container} in the container.")

# Second argument is the name of the container instance
instance = sys.argv[2]
print(f"The container instance will be named '{instance}'.")

# Remaining arguments: port mappings host_port:container_port
# Those mappings are used to access the container ports from the mapped host ports
# They must be formatted before being given to the Docker `run` command
port_mappings = ""
for port in sys.argv[3:]:
    # Add "-p host_port:container_port" to the string representing the port mappings
    port_mappings += f"-p {port} "


##########################################
# STEP 5: Build and run Docker container #
##########################################

# Name of the container image
image = "fdekeers/mozart-1.4.0"
# Pull container image from DockerHub
print("Pulling container image from DockerHub, please wait...")
command = f"docker pull {image}"
subprocess.run(command, shell=True)

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
command = f'docker run --rm --name {instance} -it {port_mappings} --volume="{shared_dir_host}:{shared_dir_container}:rw" -e DISPLAY={ip} {image}'
subprocess.run(command, shell=True)


######################################################################################
# CLEANING: Stop X11 server, if all the instances of the container have been stopped #
######################################################################################

# Docker command to list all running instances of the fdekeers/mozart-1.4.0 image
command = f"docker ps -aq -f ancestor={image}"
output = subprocess.run(command, shell=True, stdout=subprocess.PIPE)
if not output.stdout:
    # Output of command is empty, all the instances have been stopped
    print("Stopping X11 server.")
    # Command to kill the vcxsrv.exe process
    command = "taskkill /f /im vcxsrv.exe"
    subprocess.run(command, shell=True)
