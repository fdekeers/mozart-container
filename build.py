'''
Python script to build and deploy the Mozart 1.4 container on Windows.

Author: François De Keersmaeker
'''

import os, subprocess, hashlib

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
    Searches for a file in the whole directory tree,
    and returns its path.
    From https://stackoverflow.com/questions/1724693/find-a-file-in-python
    '''
    for path in ["C:\\", "D:\\"]:
        for root, dirs, files in os.walk(path):
            if filename in files:
                return os.path.join(root, filename)


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

# VcSrv SourceForge download link
vcxsrv_url = "https://downloads.sourceforge.net/project/vcxsrv/vcxsrv/1.20.9.0/vcxsrv-64.1.20.9.0.installer.exe"
vcxsrv_file = "vcxsrv-64.1.20.9.0.installer.exe"
vcxsrv_md5 = "3fe9fbdcc47b934cdd8e0c01f9008125"

# Download VcXsrv installer
print("Downloading VcXsrv to allow GUI applications inside Docker.")
command = f'powershell.exe -Command "Start-BitsTransfer -Source {vcxsrv_url}"'
subprocess.run(command, shell=True)
# Check MD5 hash of downloaded file
if compute_md5(vcxsrv_file) == vcxsrv_md5:
    # MD5 OK
    print("MD5 of downloded file verified.")
else:
    # MD5 not identical
    print("MD5 verification failed !")
    print("Please run the script again.")
    exit(-1)
# Install VcXsrv
print("Installing VcXsrv.")
subprocess.run(vcxsrv_file, shell=True)
# Remove installer file
os.remove(vcxsrv_file)


########################################
# STEP 2: Start X11 server with VcXsrv #
########################################

# Find VcXsrv executable
print("Searching for VcXsrv executable, please wait...")
vcxsrv_exec = find_file("xlaunch.exe")
# Launch executable with config file
print("Starting X11 server.")
subprocess.run(f"{vcxsrv_exec} -run config.xlaunch")


########################################
# STEP 3: Find X11 server IPv4 address #
########################################

# Save ipconfig results into file
subprocess.run("ipconfig /all > ipconfig.txt", shell=True)
# Get the X11 server IPv4 address from file, and append port
ip = f"{get_xserv_ip('ipconfig.txt')}:0.0"
# Remove file
os.remove("ipconfig.txt")


##########################################
# STEP 4: Build and run Docker container #
##########################################

# Name of the container
container = "mozart-1.4"
# Build and run container
print("Building container, please wait...")
subprocess.run(f"docker build -q -t {container} .", shell=True)
subprocess.run(f"docker run --rm --name {container} -it -e DISPLAY={ip} {container}", shell=True)
