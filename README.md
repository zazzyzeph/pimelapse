# pimelapse
Timelapse generator for a raspberry pi + camera

[Example Video](https://www.youtube.com/watch?v=q6FfKIx5Czg)

This is a couple of bash scripts to be used with `cron` that when configured correctly will take a picture from a connected Raspberry Pi camera every 10 minutes and at the end of the day, compile those photos into a video. If there's already a video on the Pi from previous days, it will append the new video onto the old one, and upload both the current day's video and the overall timelapse to Google Drive (or another service of your choice).

It is currently configured for a common ebay "IR-cut" raspberry pi camera (meaning it has infra-red LEDs attached and an IR filtering shutter [it'll switch to night vision when it's dark enough]), taking pictures at the camera's full 4:3 resolution, then resizing those images into 1080p landscape and portrait mode versions.

Timelapse videos are created daily at midnight via `ffmpeg`, usually in about 20-40 minutes depending on the length of the overall timelapse video.

The complete timelapse videos are uploaded each day to Google Drive (or anything supported by [rclone](https://rclone.org/)) as well as each individual day's timelapse video, reason being that the full timelapse video will start to degrade the earlier portions of the long timelapse videos due to the repeated h264 mp4 compression (mp4s require re-encoding when appending new content, so that can make things crunchy after a while)

## required materials
- [Raspberry Pi Zero W](https://www.adafruit.com/product/3400) (any Pi that connects to the internet really, but I'm focusing on the Zero W)
- [Raspberry Pi camera](https://www.ebay.com/sch/i.html?_from=R40&_trksid=p2380057.m570.l1313&_nkw=ir+cut+raspberry+pi&_sacat=0) connector compatible camera (I used a generic 'IR-cut' module)
- [Raspberry Pi Zero Camera Cable](https://www.adafruit.com/product/3157) (the default Pi's camera cable won't fit Zero models)
- [Raspberry Pi camera case](https://www.adafruit.com/product/3446) (optional, but I'm using this to video plants so I want to limit the possibility of the Pi getting splashed)
- [Micro SD card](https://www.adafruit.com/product/2693) (processing images/video is tough stuff and the Pi Zero is Not Fast so you want a fast SD card with at least 16gb. SanDisk Ultra or Extreme is recommended, but any non-budget card should do.)
- a [Google Drive](https://drive.google.com) account. You may want to make a new Google account for this purpose, as we'll need to give the Pi full access to whichever Google account you choose.

## Pi prep
- [download PiOS Lite](https://www.raspberrypi.org/downloads/raspberry-pi-os/) 
- [install PiOS on the SD card](https://www.raspberrypi.org/documentation/installation/installing-images/README.md)
- create [wpa_supplicant.conf](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md) - in the `boot` folder to enable WiFi
- create another file in the `boot` folder named `ssh`. it doesn't need any content. This enables us to get into the Pi from our computer to manage it manually. 
- we should be careful about security since the Pi will have a credential file for your online file storage. the below two steps are optional but highly recommended
- [enable passwordless SSH access](https://www.raspberrypi.org/documentation/remote-access/ssh/passwordless.md)
- [disable password authentication for SSH](https://www.hostgator.com/help/article/how-to-disable-password-authentication-for-ssh)
- power up the pi, wait ~40 seconds for it to boot, and from a terminal on your computer..
- `ssh pi@raspberrypi.home` should allow you to run commands from the Pi assuming all steps were followed and your Wifi information is correct.
- `sudo apt update && sudo apt upgrade` - update your software and repositories
- `sudo apt install raspi-config rclone git raspistill imagemagick ffmpeg raspi-update` install needed packages
- run `raspi-update` to get the camera firmware
- `raspi-config` - run Change Locale (probably to UTF-8), Change Timezone, Enable Camera.
- The Pi will need to reboot. `ssh pi@raspberrypi.home` again after 40 seconds to make sure it still works
- remove power and install your case and camera module
- turn it back on, wait for it to boot again and `ssh pi@raspberrypi.home`
- `raspistill -o test.jpg` - to test the camera is working. if it returns an error, make sure your camera cables are fully connected.
- `ls` should show `test.jpg`

## Pimelapse setup
- `git clone https://github.com/zazzyzeph/pimelapse.git` clone the repository into your home directory
- `crontab -e` add these two lines your crontab ([what's a cron?](https://www.raspberrypi.org/documentation/linux/usage/cron.md)):
```
*/10 * * * * /home/pi/pimelapse/camera.sh >/dev/null 2>&1
1 0 * * * /home/pi/pimelapse/endofcycle.sh >/dev/null 2>&1
```
- create a [Service Account](https://developers.google.com/identity/protocols/oauth2/service-account#creatinganaccount) for interacting with Google Drive.
- download and copy the service account's JSON file to your computer, then copy it to the Pi with SCP. example - `scp ~/Downloads/SERVICEACCOUNTFILENAME.json pi@raspberrypi.home:/home/pi`
- `rclone config` - following [this guide](https://rclone.org/drive/), we want the **service account** option because we can't  interact with a browser on the device to complete Google's standard [OAuth](https://en.wikipedia.org/wiki/OAuth) sign-in procedure. enter the location of the service account json file you copied over. 

That should be it! You should see a images start coming into the `images/` folder, and around 1:00 you should have your timelapse videos in your Google Drive in the folder you gave to rclone.