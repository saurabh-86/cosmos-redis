#!/bin/bash

PREFIX=$(cat /etc/default/cosmos-service)
INTERVAL=5

HOSTNAME=`hostname -f`

PORTS=(`ps -o command --no-headers -C "redis-server" | cut -d : -f 2`)

SECTIONS=(server clients memory persistence stats replication cpu)

while sleep "$INTERVAL"
do
    now=`date +%s`

    for PORT in ${PORTS[@]}
    do
        ROLE=$(redis-cli -p ${PORT} info replication | grep "role" | cut -d : -f 2)

        # Strip out the newline character from the end
        ROLE=${ROLE:0:${#ROLE}-1}

        for section in ${SECTIONS[@]}
        do
            info_output=$(redis-cli -p $PORT info $section)
            while read -r info_tuple
            do

            # skip lines starting with a '#'
            if [[ "$info_tuple" =~ ^\#.* ]]
            then
                continue
            fi

            param=$(echo ${info_tuple} | cut -d : -f 1)
            value=${info_tuple:${#param}+1:${#info_tuple}-${#param}-2}

            # skip non numeric values to avoid errors downstream
            if [[ "${value}" =~ ^[\+\-]?[0-9]+(\.[0-9]+)?$ ]]
            then
                echo "$now ${PREFIX}.redis.${section}.${param} ${value} port=$PORT host=$HOSTNAME role=$ROLE"
            fi
            done <<< "$info_output"
        done
    done
done
