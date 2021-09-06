'''
Python script to build and deploy an instance of the Mozart 1.4.0 container,
depending on the host operating system.

Usage: python build.py OPTIONS
Options (optional):
    * -h, --help
        Show the help message.
    * -d SHARED_DIR, --directory SHARED_DIR
        Indicate the host directory that will be shared with the container, to store (for example) Oz source code files.
        Default is ./oz-files.
    * -n NAME, --name Name
        Indicate the name of the container instance that will be deployed.
        Default is `mozart-1.4.0_n`, where `n` is the index of this instance among the running instances (starting from 0).
    * -p PORT, --port PORT
        Indicate a port mapping between a host port and a container port.
        Syntax: host_port:container_port
        A mapping means that the container port is accessible from the host port.
        To define multiple mappings, simple provide this option multiple times.
        Default mappings are 9000:9000, 33000:33000, 34000:34000, 35000:35000, 36000:36000.

Author: Francois De Keersmaeker
'''

import os, platform, subprocess, argparse

# Description of the script, used by the argument parser
description = "Build and deploy the Mozart 1.4.0 container."


# Default values for optional command line arguments

# Shared host drectory, default is ./oz-files
shared_dir = "%s\\%s" %(os.getcwd(), "oz-files")

# Name of the container instance, based on the number of already running instances:
# "mozart-1.4.0_n", where n is the index of the instance among the running instances
image = "fdekeers/mozart-1.4.0"  # Name of the container image
instance = "mozart-1.4.0_"  # Base name of the instance, without the index
command = "docker ps -aq -f ancestor=%s" % image  # Docker command to get the list of already running instances of the image mozart-1.4.0
output = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE).communicate()[0].decode("utf-8")  # Run command and retrieve output
lines = output.count("\n")  # Count the number of lines, which is equal to the number of instances running
instance += str(lines)  # Append the index number to the instance name

# Default port mappings host_port:container_port
# Those mapping are used for Windows
# such that the container ports can be accessed from the host IP address.
port_mappings = ["9000:9000", "33000:33000", "34000:34000", "35000:35000", "36000:36000"]

# Command line argument parsing, using an ArgumentParser object
# Initialize argument parser with the description of the script
parser = argparse.ArgumentParser(description=description)
# First argument: host shared directory, option `-d` or `--directory`
help = """Host directory that will be shared with the container.
Default is ./oz-files."""
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
shared_dir = os.path.abspath(args.directory) if args.directory else shared_dir
instance = args.name if args.name else instance
port_mappings = args.port if args.port else port_mappings

# Argument formatting
args = "\"%s\" %s" % (shared_dir, instance)
for port in port_mappings:
    args += " %s" % port

# Run script for Windows
os.system("python windows\\build.py " + args)
