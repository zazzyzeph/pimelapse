

#!/bin/bash

DATE=$(date +"%Y-%m-%d_%H%M")

raspistill -w 1920 -h 1920 -q 80 -awb sun -o /home/pi/camera/$DATE.jpg
