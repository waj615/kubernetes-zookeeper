#!/bin/bash

echo ${MYID:-1} > /opt/zookeeper/data/myid

# SERVERS and CLIENT_PORT inputs exist for test and other uses outside kubernetes of this container. 

if [ -n "$SERVERS" ]; then
	IFS=\, read -a servers <<<"$SERVERS"
	for i in "${!servers[@]}"; do 
		printf "\nserver.%i=%s" "$((1 + $i))" "${servers[$i]}" >> /opt/zookeeper/conf/zoo.cfg
	done
fi

printf "\nclientPort=%i" "${CLIENT_PORT:-2181}" >> /opt/zookeeper/conf/zoo.cfg

# Within kubernetes, we rely on the service environment variables.

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
