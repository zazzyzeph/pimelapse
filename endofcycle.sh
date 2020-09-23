#!/bin/bash

# setup requires rclone (and running rclone config, naming the remote [remote], and then making a new folder in your remote [example here is tentpicamera])
# and you may need to raspi-update (grab new firmware) to get the camera modules if you installed PiOS lite

DATE=$(date +"%Y-%m-%d")

# tar.xz and back up jpgs. i decided not to do this anymore because it takes a really long time
# and it still comes out to 150mb for a day's worth (144) of 1920x1080 80% quality JPEGs, and xz is a very good compression algorithm

# cd ~/camera

# tar cJvf ../$DATE.tar.xz *.jpg

# cd ~

# rclone copy $DATE.tar.xz "remote:tentpicamera/"


# camera takes large 4:3 shots, so I use those to make 16:9 (landscape) and 9:16 (portrait) videos
# however, h264_omx really only works with the common "HD" resolutions (ie 1080p, 720p) and only in landscape
# so we're gonna take the full size images and scale -> crop, and rotate the 9:16 ones to be 16:9
# rotating it upright can be done in other software on your computer / phone more efficiently.

cp -r camera/*.jpg wide_camera/
cp -r camera/*.jpg tall_camera/

# removing base images here because the mogrify/ffmpeg stuff can take ~30 minutes and we don't want to lose any frames by deleting after its done
rm camera/*

mogrify -resize 1920 +repage -gravity Center -crop 1920x1080+0+0 +repage wide_camera/*.jpg
mogrify -resize x1920 +repage -gravity Center -crop 1080x1920+0+0 +repage -rotate 90 +repage tall_camera/*.jpg

# convert the jpgs to an mp4
# -c:v = codec:video, using h264_omx codec because it's GPU accelerated on the Pi Zero
# -b:v = bitrate for video, which needs to be at 5.12Mbps for 1080p video.
# -an = audio none
# -y = dont prompt for overwriting files

ffmpeg -pattern_type glob -i 'wide_camera/*.jpg' -c:v h264_omx -an -video_size 1920x1080 -b:v 5.12M -y wide_camera_$DATE.mp4
ffmpeg -pattern_type glob -i 'tall_camera/*.jpg' -c:v h264_omx -an -video_size 1920x1080 -b:v 5.12M -y tall_camera_$DATE.mp4

rclone copy wide_camera_$DATE.mp4 "remote:tentpicamera/wide_camera"
rclone copy tall_camera_$DATE.mp4 "remote:tentpicamera/tall_camera"

# stick the new video onto the end of the timelapse video
# we're using the filter_complex method because concatenating mp4 files requires re-encoding.
# there's no audio so no a: arguments, and we need to make a new file because ffmpeg wont edit the file in place

ffmpeg -i wide_camera_timelapse.mp4 -i wide_camera_$DATE.mp4 -filter_complex "[0:v] [1:v] concat=n=2:v=1 [v]" -map "[v]" -b:v 5.12M -c:v h264_omx wide_camera_newtimelapse.mp4
ffmpeg -i tall_camera_timelapse.mp4 -i tall_camera_$DATE.mp4 -filter_complex "[0:v] [1:v] concat=n=2:v=1 [v]" -map "[v]" -b:v 5.12M -c:v h264_omx tall_camera_newtimelapse.mp4

mv wide_camera_newtimelapse.mp4 wide_camera_timelapse.mp4
mv tall_camera_newtimelapse.mp4 tall_camera_timelapse.mp4

rclone copy wide_camera_timelapse.mp4 "remote:tentpicamera/wide_camera"
rclone copy tall_camera_timelapse.mp4 "remote:tentpicamera/tall_camera"

rm -f wide_camera/*.jpg tall_camera/*.jpg wide_camera_$DATE.mp4 tall_camera_$DATE.mp4

# gifs makins, if you want. they're way bigger than mp4s, even at 640x480. todo: concatenate gifs. should be easy with imagemagick commands

# mogrify -resize 640x480 camera/*.jpg

# convert -delay 10 -loop 0 camera/*.jpg $DATE.gif

# rclone copy $DATE.gif "remote:tentpicamera/"
