#!/bin/bash
exec 1> >(exec logger -p user.info -t "$(basename $(pwd))[$(cat $(pwd)/supervise/pid)]")
exec 2> >(exec logger -p user.err -t "$(basename $(pwd))[$(cat $(pwd)/supervise/pid)]")
# ssl : https://github.com/mesosphere/marathon/issues/2545
export JAVA_OPTS="-Xmx1024m -Dlog4j.configuration=file:///etc/marathon/log4j.properties -Dconfig.file=/etc/marathon/application.conf"
exec /usr/bin/marathon