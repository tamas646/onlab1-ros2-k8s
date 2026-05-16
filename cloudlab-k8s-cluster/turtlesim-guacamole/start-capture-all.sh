#!/bin/bash

IFACES=(
# list network interface names here
)

for iface in ${IFACES[@]}
do
	tcpdump -w `dirname $0`/tcpdump_$(hostname -s)_$iface.pcap -i $iface &
done

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

echo "Press enter to stop the capture..."
read
echo "Capture stopped. Exiting..."
