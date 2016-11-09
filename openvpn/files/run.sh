#!/bin/bash
exec 1> >(exec logger -p user.info -t "$(basename $(pwd))[$(cat $(pwd)/supervise/pid)]")
exec 2> >(exec logger -p user.err -t "$(basename $(pwd))[$(cat $(pwd)/supervise/pid)]")
exec /usr/sbin/openvpn --cd /etc/openvpn/ --config /etc/openvpn/openvpn.conf