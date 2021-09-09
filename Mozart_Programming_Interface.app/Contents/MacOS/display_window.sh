#!/bin/zsh

# Zsh script to make the Mozart window visible when started,
# by toggling fullscreen on and off on the Mozart window.
# This script should not be run alone, and should only
# be called by the Python script `display_window.sh`.
#
# Authors: DEFRERE Sacha, DE KEERSMAEKER Francois, KUPERBLUM Jeremie

# Initial number of windows on screen
number=$(wmctrl -l | wc -l)

# Loop while there is no new window
while [[ $(wmctrl -l | wc -l) -eq $number ]] do
    continue
done
# End of loop, a new window appeared, which is the Mozart window

# Get the identifier of the Mozart window
win=$(wmctrl -l | sed -n $((number+1))p | cut -d' ' -f4)

# Toggle fullscreen on and off
wmctrl -r $win -b add,fullscreen
wmctrl -r $win -b remove,fullscreen
