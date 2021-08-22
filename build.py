'''
Python script to build and deploy the Mozart 1.4 container on Windows.

Author: François De Keersmaeker
'''

import os, subprocess

# Name of the container
container = "mozart-1.4"
# Full name of the X11 server network interface
interface = "VirtualBox Host-Only Ethernet Adapter"

def contains_interface(str):
    '''
    Checks if `str` contains the X11 server interface name.
    '''
    return interface in str


def get_xserv_ip(filename):
    '''
    Retrieves the IPv4 address associated to an X11 server,
    from an `ipconfig` file output.
    Returns `None` if no X11 IPv4 address was found.
    '''
    found_interface = False
    with open(filename, "r") as file:
        for line in file.readlines():
            if not found_interface and interface in line:
                # Found the information block about the interface
                found_interface = True
            if found_interface and "IPv4" in line:
                # Found the line with the IPv4 address, extract address
                ip = line.split(":")[1].strip()
                ip = ip.partition("(")[0].strip()
                return ip
    return None


# Save ipconfig results in file
subprocess.run("ipconfig /all > ipconfig.txt", shell=True)
# Get the X11 server IPv4 address from file, and append port
ip = f"{get_xserv_ip('ipconfig.txt')}:0.0"
# Remove file
os.remove("ipconfig.txt")

# Build and run container
print("Please wait while the container is built...")
subprocess.run(f"docker build -q -t {container} .", shell=True)
subprocess.run(f"docker run --rm --name {container} -it -e DISPLAY={ip} {container}", shell=True)
