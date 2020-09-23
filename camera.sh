

#!/bin/bash

DATE=$(date +"%Y-%m-%d_%H%M")

raspistill -w 2592 -h 1944 -q 80 -awb sun -o /home/pi/camera/$DATE.jpg
