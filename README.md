# pimelapse
Timelapse generator for a raspberry pi (3, zero 2w, probably 4 and 5) + camera

[Example Video](https://www.youtube.com/watch?v=q6FfKIx5Czg)

This is a couple of bash scripts to be used with `cron` that when configured correctly will take a picture from a connected Raspberry Pi camera every 10 minutes and at the end of the day, compile those photos into a video. If there's already a video on the Pi from previous days, it will append the new video onto the old one, and upload both the current day's video and the overall timelapse to Google Drive (or another service of your choice).

It is configured to take pictures at 1920x1080 (aka 1080p)

Timelapse videos are created daily at midnight via `ffmpeg`, usually in about 20-40 minutes depending on the length of the overall timelapse video.


## Pi prep
- [Download and install the Raspberry Pi Imager](https://www.raspberrypi.org/downloads/raspberry-pi-os/) 
- Set up your WiFi login information, and enable SSH access in the settings dialog
  - I recommend [generating ssh keys](https://www.redhat.com/sysadmin/passwordless-ssh) and disabling password authentication. 
- power up the pi, wait ~40 seconds for it to boot, and from a terminal on your computer..
- `ssh pi@raspberrypi.home` should allow you to run commands from the Pi assuming all steps were followed and your Wifi information is correct.
- `sudo apt update && sudo apt upgrade` - update your software and repositories
- `sudo apt install rclone git imagemagick ffmpeg` install needed packages
- `libcamera-jpeg -o test.jpg` - to test the camera is working. if it returns an error, make sure your camera cables are fully connected.
- `ls` should show `test.jpg`

## Pimelapse setup
- `git clone https://github.com/zazzyzeph/pimelapse.git` clone the repository into your home directory
- `crontab -e` add these two lines your crontab ([what's a cron?](https://www.raspberrypi.org/documentation/linux/usage/cron.md)):
```
*/10 * * * * /home/pi/pimelapse/camera.sh >/dev/null 2>&1
1 0 * * * /home/pi/pimelapse/endofcycle.sh >/dev/null 2>&1
```

Whenver you want your timelapse video:
```
scp <your pi's username>:<your pi's hostname or ip address> /home/<username>/pimelapse/compilations/timelapse.mp4 <the/directory/where/you/want/the/file>
```
^ this assumes you have `ssh` installed :)


optional steps for getting rclone set up so your timelapse video uploads to google drive:
- create a [Service Account](https://developers.google.com/identity/protocols/oauth2/service-account#creatinganaccount) for interacting with Google Drive.
- download and copy the service account's JSON file to your computer, then copy it to the Pi with SCP. example - `scp ~/Downloads/SERVICEACCOUNTFILENAME.json pi@raspberrypi.home:/home/pi`
- `rclone config` - following [this guide](https://rclone.org/drive/), we want the **service account** option because we can't  interact with a browser on the device to complete Google's standard [OAuth](https://en.wikipedia.org/wiki/OAuth) sign-in procedure. enter the location of the service account json file you copied over. 

That should be it! You should see timelapse.mp4 in the complations folder, and the day's video in 