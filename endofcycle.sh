#!/bin/bash

# if you want to use google drive to back up your images:
# ------------
# sudo apt install rclone
# rclone config
# ------------
# in rclone config - name the remote [remote], and make new folders [example here is 'tentpicamera', which is in the base of my google drive. inside tentpicamera is a folder named 'videos' and another named 'compilations']

DATE=$(date +"%Y-%m-%d")
PIMELAPSE_DIR=$HOME/pimelapse

# convert the jpgs to an mp4
# -c:v = codec:video, using h264_v4l2m2m codec because it's GPU accelerated. These commands can be adapted to use the h264_omx encoder on pi0/pi1 with debian buster (pios legacy)
# -b:v = bitrate for video, which needs to be at 5.12Mbps for 1080p video.
# -an = audio none
# -y = dont prompt for overwriting files
ffmpeg -thread_queue_size 1024 -y -framerate 60 -r 60 -an -pattern_type glob -i "$PIMELAPSE_DIR/images/*.jpg" -c:v h264_v4l2m2m -an -b:v 5.12M -pix_fmt yuv420p $PIMELAPSE_DIR/videos/$DATE.mp4

# clear the images directory for the next batch
rm -f $PIMELAPSE_DIR/images/*.jpg

# reverse today's timelapse and put it in the temp directory
ffmpeg -thread_queue_size 1024 -y -i $PIMELAPSE_DIR/videos/$DATE.mp4 -c:v h264_v4l2m2m -an -b:v 5.12M -pix_fmt yuv420p -filter:v "reverse" $PIMELAPSE_DIR/temp/${DATE}_reverse.mp4

# copy today's timelapse and put it in temp too
cp $PIMELAPSE_DIR/videos/$DATE.mp4 $PIMELAPSE_DIR/temp

# this concats today's timelapse and the reversed version to make a video we can use as a back-and-forth loop with the HTML5 video element
ffmpeg -thread_queue_size 1024 -y -f concat -safe 0 -i <(for f in $PIMELAPSE_DIR/temp/*.mp4; do echo "file '$f'"; done) -c copy $PIMELAPSE_DIR/compilations/today_loop.mp4

# delete videos in the temp folder
rm -f $PIMELAPSE_DIR/temp/*.mp4

# rclone copy $HOME/videos/$DATE.mp4 "remote:tentpicamera/videos"

# do a quick concat/copy of all the files in $PIMELAPSE_DIR/videos/ to make the full timelapse
ffmpeg -thread_queue_size 1024 -y -f concat -safe 0 -i <(for f in $PIMELAPSE_DIR/videos/*.mp4; do echo "file '$f'"; done) -c copy $PIMELAPSE_DIR/compilations/timelapse.mp4

# rclone copy timelapse.mp4 "remote:tentpicamera/videos"






# gifs makins, if you want. they're way bigger than mp4s, even at 640x480. todo: concatenate gifs. should be easy with imagemagick commands

# mogrify -resize 640x480 camera/*.jpg

# convert -delay 10 -loop 0 camera/*.jpg $DATE.gif

# rclone copy $DATE.gif "remote:tentpicamera/"
