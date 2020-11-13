#!/bin/bash

cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
find /var/log -type f -delete
rm -rf /var/log/journal/*
rm -f /var/lib/dhcpcd5/*
dd if=/dev/zero of=/EMPTY bs=1M || true; sync; sleep 1; sync
rm -f /EMPTY; sync; sleep 1; sync
unset HISTFILE && history -c && rm -fr /root/.bash_history
rm -fr /home/pi/.bash_history
shutdown -h now