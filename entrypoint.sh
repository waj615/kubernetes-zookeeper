#!/bin/bash

echo ${MYID:-1} > /opt/zookeeper/data/myid

client="ZOOKEEPER_${MYID}_SERVICE_PORT_CLIENT"
printf "\nclientPort=%i" "${!client:-2181}" >> /opt/zookeeper/conf/zoo.cfg

for i in 1 2 3
do
	host="ZOOKEEPER_${i}_SERVICE_HOST"
	followers="ZOOKEEPER_${i}_SERVICE_PORT_FOLLOWERS"
	election="ZOOKEEPER_${i}_SERVICE_PORT_ELECTION"
	if [ -n "${!host}" ]; then
		printf "\nserver.%i=%s" "$i" "${!host}:${!followers}:${!election}" >> /opt/zookeeper/conf/zoo.cfg
	fi
done

cd /opt/zookeeper
exec "$@"
