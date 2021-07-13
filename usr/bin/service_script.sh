#!/bin/bash

mkfifo /tmp/notifyfifo
chomod 777 /tmp/notifyfifo

systemd-notify --ready --status "Waiting for data"

while : ; do
    read a < /tmp/notifyfifo
    systemd-notify --status="Processing script"
    echo -e "\n$(date +"%m-%d-%y %T")\tSleep script was started" >> /tmp/service_script.log
done
