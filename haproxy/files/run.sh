#!/bin/sh
mkdir -p /run/haproxy/
exec /usr/sbin/haproxy-systemd-wrapper -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid