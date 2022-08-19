#!/bin/bash
# Script Name: View GTK default icons using yad & bash
# Author: Robert Cooper, Offternet.com, admin@yadportal.com
# ver: 1.0
# Date: 2022/08/17
# License: GPL 3
# Research: Yad Gui Group - https://groups.google.com/g/yad-common
# Yad Author is: Victor Ananjevsky

# SPECIAL INSTALL Instructions - copy yad to yad2. For example on Debian.-> sudo cp /usr/local/bin/yad /usr/local/bin/yad
# yad2 is used to close all icon displayed after Drag & Drop.

KEY=$RANDOM

# Note the use in function below of yad2. yad2 is same as yad program just with a different file name
# This was easy way for me to keep main script up and close yad icon display windows.

function uri_hndl  {
    yad2 --width=100 --height=100 --html --browser --uri="${1:7}"
}
export -f uri_hndl

yad --plug=$KEY --tabnum=1  --text="Browse icon - folders below. Then Drag and Drop ICON Here" --dnd --back=BLACK --use-interp --command='uri_hndl "%s"' &

yad --plug=$KEY --text="/usr/share/icons" --tabnum=2 \
yad --html --browser --uri="file:///usr/share/icons" &

yad --paned --key=$KEY --width=1000 --height=700  --center --title="View GTK default icons using yad & bash" \
--button="Close Icons:bash -c 'killall yad2'" --button="yad-close" --key=$KEY --tab="Text File" --tab="Yad Group"
