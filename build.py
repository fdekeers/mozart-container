'''
Python script to build and deploy the Mozart 1.4.0 container,
depending on the host architecture.

Author: Francois De Keersmaeker
'''

import sys, os, platform, subprocess

# Check OS
system = platform.system()

oz_dir_host = ""

# Get command line arguments
if len(sys.argv) > 1:
    oz_dir_host = sys.argv[1]  # Arg 1: Oz directory on the host

# Define name of the container, based on the number of already running containers
container = "mozart-1.4.0_"
command = "docker ps -aq -f ancestor=mozart-1.4.0"
if system == "Linux":
    # Linux command needs to add `sudo`
    command = "sudo " + command
output = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE).communicate()[0].decode('utf-8')
lines = output.count("\n")
print(lines)
container += str(lines)

# Run script for the identified OS
if system == "Linux":
    print("Your OS is Linux.")
    os.system("linux/build.sh %s %s" % (container, oz_dir_host))
elif system == "Windows":
    print("Your OS is Windows.")
    os.system("python windows\\build.py %s %s" % (container, oz_dir_host))
elif system == "Darwin":  # MacOS
    print("Your OS is MacOS.")
    os.system("mac-os/build.sh %s %s" % (container, oz_dir_host))
