#!/bin/bash

# Bash script to install the Mozart 1.4.0 container
# as a Desktop application on Linux platforms.
#
# Usage: ./install.sh
#
# Please run this script once before using the container,
# to install it as a Linux desktop application.
# Afterwards, the container can be deployed by clicking
# on the corresponding desktop application.
#
# Authors: DEFRERE Sacha, DE KEERSMAEKER Francois, KUPERBLUM Jeremie


# Parent directory of this script
# From: https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Make the python script executable
chmod +x $SCRIPT_DIR/build.py

# Create a file describing the application,
# in ~/.local/share/applications,
# such that it appears in the list of applications.
echo "[Desktop Entry]
Version=1
Type=Application
Terminal=true
Exec=$SCRIPT_DIR/build.py
Name=Mozart Programming Interface
Icon=$SCRIPT_DIR/resources/icon.ico
Categories=Development;IDE;" > ~/.local/share/applications/Mozart_Programming_Interface.desktop

echo "Installation complete."
echo "You can now run the Mozart 1.4.0 container as a Linux application."
