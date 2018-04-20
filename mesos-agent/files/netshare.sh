#!/bin/bash
exec 1> >(exec logger -p user.info -t "$(basename $(pwd))[$(cat $(pwd)/supervise/pid)]")
exec 2> >(exec logger -p user.err -t "$(basename $(pwd))[$(cat $(pwd)/supervise/pid)]")
export SOURCE_MAP_FILE=/etc/netshare.map
[ -e $SOURCE_MAP_FILE ] || touch $SOURCE_MAP_FILE
exec /usr/bin/docker-volume-netshare --basedir=/srv nfs -o port=2049,nolock,proto=tcp,nfsvers=3 --version=3