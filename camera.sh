#!/bin/bash

PIMELAPSE_DIR=$HOME/pimelapse
DATE=$(date +"%Y-%m-%d_%H%M")

libcamera-still --width 1920 --height 1080 --awb daylight --exposure -1 -o $PIMELAPSE_DIR/images/$DATE.jpg 
