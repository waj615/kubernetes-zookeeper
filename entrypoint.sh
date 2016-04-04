#!/bin/bash

echo ${MYID:-1} > /opt/zookeeper/data/myid

if [ -n "$SERVERS" ]; then
	IFS=\, read -a servers <<<"$SERVERS"
	for i in "${!servers[@]}"; do 
		printf "\nserver.%i=%s:2888:3888" "$((1 + $i))" "${servers[$i]}" >> /opt/zookeeper/conf/zoo.cfg
	done
fi

cd /opt/zookeeper
exec "$@"
