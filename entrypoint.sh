#!/bin/bash

echo ${MYID:-1} > /opt/zookeeper/data/myid

if [ -n "$SERVERS" ]; then
	IFS=\, read -a servers <<<"$SERVERS"
	for i in "${!servers[@]}"; do 
		printf "\nserver.%i=%s" "$((1 + $i))" "${servers[$i]}" >> /opt/zookeeper/conf/zoo.cfg
	done
fi

printf "\nclientPort=%i" "${CLIENT_PORT:-2181}" >> /opt/zookeeper/conf/zoo.cfg

cd /opt/zookeeper
exec "$@"
