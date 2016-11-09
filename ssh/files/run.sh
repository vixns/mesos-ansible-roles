#!/bin/bash
exec 1> >(exec logger -p user.info -t "$(basename $(pwd))[$(cat $(pwd)/supervise/pid)]")
exec 2> >(exec logger -p user.err -t "$(basename $(pwd))[$(cat $(pwd)/supervise/pid)]")
SSHD=$(which sshd) || sv down $(pwd)
PRIVSEP_DIR=/var/run/sshd
mkdir -p "$PRIVSEP_DIR"
exec "$SSHD" -D -p 22 -p 2222