#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 domain [domain] [domain] ..."
  exit 1
fi

mesos-execute \
--master=leader.mesos.service.asl:5050 \
--name=acme \
--networks=loopback,vlan \
--docker_image=vixns/acme-tiny:latest \
--resources="cpus:0.01;mem:32" \
--principal=acme \
--secret=A56BCA3C-256D-49BF-BAF7-925AE175885D \
--volumes="[{\"container_path\":\"/var/www/challenges\",\"mode\":\"RW\",\"source\":{\"docker_volume\":{\"driver\":\"nfs\",\"driver_options\":{\"parameter\":[{\"key\":\"share\",\"value\":\"10.16.103.16:/zpool-124595/config/haproxy/challenges\"}]},\"name\":\"acmechallenges\"},\"type\":\"DOCKER_VOLUME\"}},{\"container_path\":\"/etc/acme\",\"mode\":\"RW\",\"source\":{\"docker_volume\":{\"driver\":\"nfs\",\"driver_options\":{\"parameter\":[{\"key\":\"share\",\"value\":\"10.16.103.16:/zpool-124595/config/acme\"}]},\"name\":\"acmecerts\"},\"type\":\"DOCKER_VOLUME\"}}]" \
--command="/acme-tiny/get_cert.sh $@"