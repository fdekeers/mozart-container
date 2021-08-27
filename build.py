'''
Python script to build and deploy the Mozart 1.4.0 container,
depending on the host architecture.

Author: Francois De Keersmaeker
'''

import sys, os, platform, subprocess, argparse

# Description of the script
description = "Build and deploy the Mozart 1.4.0 container."

# Check OS
system = platform.system()

# Default values for command line arguments
# Shared host drectory
shared_dir = "oz-files"
if system == "Windows":
    shared_dir = "%s\\%s" %(os.getcwd(), shared_dir)
else:
    shared_dir = "%s/%s" %(os.getcwd(), shared_dir)
# Name of the container instance, based on the number of already running containers
instance = "mozart-1.4.0_"
command = "docker ps -aq -f ancestor=mozart-1.4.0"
if system == "Linux":
    # Linux command needs to add `sudo`
    command = "sudo " + command
output = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE).communicate()[0].decode("utf-8")
lines = output.count("\n")
instance += str(lines)
# Port mappings host:container
port_mappings = ["33000:33000", "34000:34000", "35000:35000", "36000:36000", "37000:37000"]

# Initialize argument parser
parser = argparse.ArgumentParser(description=description)
# First argument: host shared directory
parser.add_argument("-d", "--directory", type=str,
                    help="host directory that will be shared with the container")
# Second argument: container instance name
parser.add_argument("-n", "--name", type=str,
                    help="name of the container instance")
# Third argument: Port mappings between host and container
parser.add_argument("-p", "--port", type=str, action="append",
                    help="port mapping host_port:container_port")
# Parse arguments
args = parser.parse_args()
shared_dir = os.path.abspath(args.directory) if args.directory else shared_dir
instance = args.name if args.name else instance
port_mappings = args.port if args.port else port_mappings

# Argument formatting for OS-specific scripts
args = "%s %s" % (shared_dir, instance)
for port in port_mappings:
    args += " %s" % port

# Run script for the identified OS
if system == "Linux":
    print("Your OS is Linux.")
    os.system("linux/build.sh " + args)
elif system == "Windows":
    print("Your OS is Windows.")
    os.system("python windows\\build.py " + args)
elif system == "Darwin":  # MacOS
    print("Your OS is MacOS.")
    os.system("mac-os/build.sh " + args)
