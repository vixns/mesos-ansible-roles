#!/bin/sh
exec 2>&1
mkdir -p /var/run/openntpd
exec /usr/sbin/openntpd -s -d -f /etc/openntpd/ntpd.conf 2> /var/log/ntpd.log