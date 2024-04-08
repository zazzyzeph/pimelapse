#!/bin/bash

PIMELAPSE_DIR=$HOME/pimelapse
DATE=$(date +"%Y-%m-%d_%H%M")

libcamera-jpeg --width 1920 --height 1080 --awb daylight --ev -1 -q 100 -n -o $PIMELAPSE_DIR/images/$DATE.jpg 
