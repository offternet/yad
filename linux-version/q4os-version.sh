#!/bin/bash

#Script to display which version Q4OS you are using on your computer

IMAGE_Orion=./q4os_orion.jpg
IMAGE_Scorpion=./q4os_scorpion.jpg

version=$(grep -Po '(?<=GNU/Linux )[0-9]+' /etc/issue 2>/dev/null)

yad --title="YadBash.com" --text="Now Checking Q4OS Version" --center --timeout=3 --width=300 --height=300 --no-buttons

case "$version" in 

8) 
yad --title="You are Running Q4OS Orion" --center --form --columns=1 --no-buttons \
--width=300 \
--height=300 \
--image $IMAGE_Orion
;; 

9) 
yad --title="You are Running Q4OS Scorpion" --center --form --columns=1 --no-buttons \
--width=300 \
--height=300 \
--image $IMAGE_Scorpion
;; 

esac