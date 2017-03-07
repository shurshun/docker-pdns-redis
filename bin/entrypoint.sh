#!/bin/sh

redis-server /etc/redis.conf > /dev/stdout 2>&1 &

sleep 1;

while [[ $(redis-cli -s /tmp/redis.sock info|grep master_link_status |cut -d ':' -f 2 | xargs -n 1 echo -n || echo -n down) != "up" ]]
do
	sleep 1;
done

pdns_server
