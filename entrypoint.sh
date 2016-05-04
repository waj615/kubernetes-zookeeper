#!/bin/bash

if [ "$MYID" == "monitor" ]; then
	while :
	do
		for i in 1 2 3 4 5
		do
			host="ZOOKEEPER_${i}_SERVICE_HOST"
			port="ZOOKEEPER_${i}_SERVICE_PORT_CLIENT"
			if [ -n "${!host}" ]; then
				mntr=$(echo mntr | nc "${!host}" "${!port}" | tr ',:' '  ' | tr '\n' ',' | tr '\t' ':')
				mntr=${mntr//:/:\"}
				mntr=${mntr//,/\",}
				printf "{${mntr}service:\"zookeeper\",myid:\"${i}\"}\n"
				sleep 20
			fi
		done
	done
fi

echo ${MYID:-1} > /opt/zookeeper/data/myid

client="ZOOKEEPER_${MYID}_SERVICE_PORT_CLIENT"
printf "\nclientPort=%i" "${!client:-2181}" >> /opt/zookeeper/conf/zoo.cfg

for i in 1 2 3 4 5
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
