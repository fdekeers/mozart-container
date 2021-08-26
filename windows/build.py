'''
Python script to build and deploy the Mozart 1.4.0 container on Windows.

Author: Francois De Keersmaeker
'''

import os, sys, subprocess, hashlib

# Full name of the X11 server network interface
x11_interface = "VirtualBox Host-Only Ethernet Adapter"


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


def get_xserv_ip(filename):
    '''
    Retrieves the IPv4 address associated to an X11 server,
    from an `ipconfig` file output.
    Returns `None` if no X11 IPv4 address was found.
    '''
    found_interface = False
    with open(filename, "r") as file:
        for line in file.readlines():
            if not found_interface and x11_interface in line:
                # Found the information block about the interface
                found_interface = True
            if found_interface and "IPv4" in line:
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
    sys.stderr.write("Could not find VcXsrv executable.")
    sys.stderr.write("Please check VcXsrv installation.")
    exit(-1)
# Launch executable with config file
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
# Get the X11 server IPv4 address from file
ip = get_xserv_ip(filename)
# Remove file
os.remove(filename)
# Check if IP was found
if ip is None:
    # IP was not found, exit
    sys.stderr.write("Could not find X11 server IP.")
    sys.stderr.write("Please check VcXsrv installation.")
    exit(-1)
# Add port to address
ip = f"{ip}:0.0"


######################################
# STEP 3: Get command line arguments #
######################################

# Name of the container
image = "mozart-1.4.0"  # Image
instance = image        # Instance
# Directories for Oz files
oz_dir_host = f"{os.getcwd()}\oz-files"   # Host
oz_dir_container = "/root/oz-files"       # Container

# First (optional) argument is the directory containing the Oz files
if len(sys.argv) > 1:
    path = sys.argv[1]  # New Oz directory
    oz_dir_host = os.path.abspath(path)
    oz_dir_container = f"/root/{os.path.basename(path)}"
print(f"Oz files are in {oz_dir_host} on the host.")
print(f"They will be placed in {oz_dir_container} inside the container.")

# Second (optional) argument is the name of the container instance
if len(sys.argv) > 2:
    instance = sys.argv[2]
print(f"The container instance will be named '{instance}'.")


##########################################
# STEP 5: Build and run Docker container #
##########################################

# Build and run container
print("Building container, please wait...")
command = f"docker build -t {image} ."
subprocess.run(command, shell=True)
command = f'docker run --rm --name {sys.argv[1]} -it --volume="{oz_dir_host}:{oz_dir_container}:rw" -e DISPLAY={ip} {image}'
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
