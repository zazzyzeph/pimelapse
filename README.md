# pimelapse
Timelapse generator for a raspberry pi + camera

This is a collection of scripts that when configured correctly will take a picture from a connected Raspberry Pi camera every 10 minutes, and then compile those photos into a video every day.

It is currently configured for a common ebay "IR-cut" raspberry pi camera (meaning it has infra-red LEDs attached and an IR filtering shutter [it'll switch to night vision when it's dark enough]), taking pictures at the camera's full 4:3 resolution, then resize those images into 1080p landscape and portrait mode versions.

Timelapse videos are created daily at midnight via `ffmpeg`. If there is a timelapse video from the previous day, the Pi will append the new video to the old one.

The complete timelapse videos are uploaded each day to Google Drive (or anything supported by [rclone](https://rclone.org/)) as well as each individual day's timelapse video, reason being that the full timelapse video will start to degrade the earlier portions of the long timelapse videos due to the repeated h264 mp4 compression (mp4s require re-encoding when appending new content, so that can make things crunchy after a while)

## required materials
- [Raspberry Pi Zero W](https://www.adafruit.com/product/3400) (any Pi that connects to the internet really, but I'm focusing on the Zero W)
- [Raspberry Pi camera](https://www.ebay.com/sch/i.html?_from=R40&_trksid=p2380057.m570.l1313&_nkw=ir+cut+raspberry+pi&_sacat=0) connector compatible camera (I used a generic 'IR-cut' module)
- [Raspberry Pi Zero Camera Cable](https://www.adafruit.com/product/3157) (the default Pi's camera cable won't fit Zero models)
- [Raspberry Pi camera case](https://www.adafruit.com/product/3446) (optional, but I'm using this to video plants so I want to limit the possibility of the Pi getting splashed)
- [Micro SD card](https://www.adafruit.com/product/2693) (processing images/video is tough stuff and the Pi Zero is Not Fast so you want a fast SD card with at least 16gb. SanDisk Ultra or Extreme is recommended, but any non-budget card should do.)
- a [Google Drive](https://drive.google.com) account

## Pi prep
- [download PiOS Lite](https://www.raspberrypi.org/downloads/raspberry-pi-os/) 
- [install PiOS on the SD card](https://www.raspberrypi.org/documentation/installation/installing-images/README.md)
- create a text file in the `boot` folder to [enable WiFi](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md)
- create another file in the `boot` folder named `ssh`. it doesn't need any content. This enables us to get into the Pi from our computer to manage it manually. 
- SSH, while a secure protocol, should be managed carefully, especially because we need to give your Pi full access to your Google account! for that reason we're going to...
- [enable passwordless SSH access](https://www.raspberrypi.org/documentation/remote-access/ssh/passwordless.md)
- [disable password authentication for SSH](https://www.hostgator.com/help/article/how-to-disable-password-authentication-for-ssh)
- the above two steps make sure that if someone got into your home network, they couldn't get into your Pi, and then get your Google credentials even if they somehow managed to get the username and password to the Pi. The only way to access the Pi is from SSH on your computer or by pulling the Pi's SD card.
- power up the pi, wait ~40 seconds for it to boot, and from a terminal on your computer..
- `ssh pi@raspberrypi.home` from a terminal / SSH app of your choice should put you in the Pi assuming all steps were followed and your Wifi information is correct.
- run `raspi-update` to get the camera firmware
- `sudo apt install raspi-config rclone git raspistill`
- `raspi-config` - run Change Locale (probably to UTF-8), Change Timezone, Enable Camera.
- The Pi will need to reboot. `ssh pi@raspberrypi.home` again after 40 seconds

## Pimelapse setup
- `git clone https://github.com/zazzyzeph/pimelapse.git` clone the repository into your home directory
- `crontab -e` add these two lines your crontab ([what's a cron?](https://www.raspberrypi.org/documentation/linux/usage/cron.md)):
```
*/10 * * * * /home/pi/pimelapse/camera.sh >/dev/null 2>&1
1 0 * * * /home/pi/pimelapse/endofcycle.sh >/dev/null 2>&1
```
- create a [Service Account](https://developers.google.com/identity/protocols/oauth2/service-account#creatinganaccount) for interacting with Google Drive.
- download and copy the service account's JSON file to your computer, then copy it to the Pi with SCP. example - `scp ~/Downloads/SERVICEACCOUNTFILENAME.json pi@raspberrypi.home:/home/pi`
- `rclone config` - following [this guide](https://rclone.org/drive/), we want the **service account** option because we can't  interact with a browser to complete a sign-in procedure. enter the location of the service account json you copied over. 

That should be it! You should see a images start coming into the `images/` folder, and around 1:00 you should have your timelapse videos in your Google Drive in the folder you gave to rclone.