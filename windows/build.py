'''
Python script to build and deploy the Mozart 1.4.0 container on Windows.

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
    Retrieves the IPv4 address from an `ipconfig` file output.
    Returns `None` if no IPv4 address was found.
    '''
    with open(filename, "r") as file:
        for line in file.readlines():
            if "IPv4" in line:
                # Found the line with the IPv4 address, extract address
                ip = line.split(":")[1].strip()
                ip = ip.partition("(")[0].strip()
                return ip
    return None


#######################################
# STEP 1: Download and install VcXsrv #
#######################################

print("VcXsrv allows GUI applications inside Docker containers.")
# Check if VcXsrv is already installed
print("Checking if VcXsrv is already installed, please wait...")
vcxsrv_exec = find_file("xlaunch.exe")
if vcxsrv_exec is None:  # VcXsrv is not installed
    print("VcXsrv is not installed.")
    # VcXsrv SourceForge download link
    vcxsrv_url = "https://downloads.sourceforge.net/project/vcxsrv/vcxsrv/1.20.9.0/vcxsrv-64.1.20.9.0.installer.exe"
    vcxsrv_file = "vcxsrv-64.1.20.9.0.installer.exe"
    vcxsrv_md5 = "3fe9fbdcc47b934cdd8e0c01f9008125"
    # Download VcXsrv installer
    print("Downloading VcXsrv installer.")
    command = f'powershell.exe -Command "Start-BitsTransfer -Source {vcxsrv_url}"'
    subprocess.run(command, shell=True)
    # Check MD5 hash of downloaded file
    if compute_md5(vcxsrv_file) != vcxsrv_md5:
        # MD5 not identical, exit
        sys.stderr.write("MD5 verification failed !")
        sys.stderr.write("Please run the script again to retry.")
        exit(-1)
    # MD5 identical, proceed
    print("MD5 of downloded file verified.")
    # Install VcXsrv
    print("Installing VcXsrv.")
    subprocess.run(vcxsrv_file, shell=True)
    # Remove installer file
    os.remove(vcxsrv_file)
    # Find VcXsrv executable
    print("Searching for VcXsrv executable, please wait...")
    vcxsrv_exec = find_file("xlaunch.exe")
else:  # VcXsrv is already installed
    print("VcXsrv is already installed.")


########################################
# STEP 2: Start X11 server with VcXsrv #
########################################

if vcxsrv_exec is None:
    # Executable not found, exit
    sys.stderr.write("Could not find VcXsrv executable.\n")
    sys.stderr.write("Please check that the VcXsrv installation was correctly done in the directory C:\\Program Files\\VcXsrv.")
    exit(-1)

# Launch VcXsrv executable with config file, if it has not been already started
command = 'tasklist /fi "ImageName eq vcxsrv.exe" /fo csv 2>NUL | find /I "vcxsrv.exe" > NUL'
if subprocess.run(command, shell=True).returncode != 0:
    # VcXsrv has not been started yet
    print("Starting X11 server.")
    command = f'"{vcxsrv_exec}" -run windows\\config.xlaunch'
    subprocess.run(command, shell=True)


########################################
# STEP 3: Find X11 server IPv4 address #
########################################

# Save ipconfig results into file
filename = ".ipconfig"
command = f"ipconfig /all > {filename}"
subprocess.run(command, shell=True)
# Get IPv4 address from file
ip = get_ip(filename)
print(f"Your local IPv4 address is {ip}")
# Remove file
os.remove(filename)
# Check if IP was found
if ip is None:
    # IP was not found, exit
    sys.stderr.write("Could not find X11 server IP.\n")
    sys.stderr.write("Please check that the VcXsrv installation was correctly done in the directory C:\\Program Files\\VcXsrv.")
    exit(-1)
# Add port to address
ip = f"{ip}:0.0"


######################################
# STEP 3: Get command line arguments #
######################################

# First argument: path of shared folder on the host
shared_dir_host = sys.argv[1]
shared_dir_container = f"/root/{os.path.basename(shared_dir_host)}"
print(f"The path of the host shared directory is {shared_dir_host}.")
print(f"It will be placed in {shared_dir_container} in the container.")

# Second argument is the name of the container instance
instance = sys.argv[2]
print(f"The container instance will be named '{instance}'.")

# Remaining arguments: port mappings host_port:container_port
port_mappings = ""
for port in sys.argv[3:]:
    port_mappings += f"-p {port} "


##########################################
# STEP 5: Build and run Docker container #
##########################################

# Name of the container image
image = "fdekeers/mozart-1.4.0"
# Pull container image from DockerHub
print("Pulling container image from DockerHub, please wait...")
command = "docker pull fdekeers/mozart-1.4.0"
subprocess.run(command, shell=True)
# Run an instance of the container
command = f'docker run --rm --name {instance} -it {port_mappings} --volume="{shared_dir_host}:{shared_dir_container}:rw" -e DISPLAY={ip} {image}'
subprocess.run(command, shell=True)


######################################################################################
# CLEANING: Stop X11 server, if all the instances of the container have been stopped #
######################################################################################

command = f"docker ps -aq -f ancestor={image}"
output = subprocess.run(command, shell=True, stdout=subprocess.PIPE)
if not output.stdout:
    # Output of Docker list is empty, no more containers
    print("Stopping X11 server.")
    command = "taskkill /f /im vcxsrv.exe"
    subprocess.run(command, shell=True)
