#!/bin/bash
exec 1> >(exec logger -p user.info -t "$(basename $(pwd))[$(cat $(pwd)/supervise/pid)]")
exec 2> >(exec logger -p user.err -t "$(basename $(pwd))[$(cat $(pwd)/supervise/pid)]")
exec /usr/bin/docker-volume-netshare --basedir=/srv nfs -o port=2049,nolock,proto=tcp --version=3