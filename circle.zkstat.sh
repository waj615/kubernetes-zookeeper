#!/bin/bash

source ./circle.env

for i in 1 2 3
do
	host="ZOOKEEPER_${i}_SERVICE_HOST"
	port="ZOOKEEPER_${i}_SERVICE_PORT_CLIENT"
	echo stat | nc "${!host}" "${!port}"
	echo mntr | nc "${!host}" "${!port}"
	
	if [[ $(echo ruok | nc "${!host}" "${!port}") != 'imok' ]]; then
		exit $i
	fi
done



