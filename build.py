'''
Python script to build and deploy the Mozart 1.4.0 container,
depending on the host architecture.

Author: Francois De Keersmaeker
'''

import sys, os, platform

oz_dir_host = ""

# Get command line arguments
if len(sys.argv) > 1:
    oz_dir_host = sys.argv[1]  # Arg 1: Oz directory on the host

# Check OS
system = platform.system()

# Run script for the identified OS
if system == "Linux":
    print("Your OS is Linux.")
    os.system("linux/build.sh %s" % oz_dir_host)
elif system == "Windows":
    print("Your OS is Windows.")
    os.system("python windows\\build.py %s" % oz_dir_host)
elif system == "Darwin":  # MacOS
    # Run MacOS script
    print("Your OS is MacOS.")
    sys.stderr.write("MacOS not implemented yet.")
