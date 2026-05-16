#!/bin/bash

IFACES=(
	datapath
	docker0
	eth0
	lo
	vethwe-bridge
	vethwe-datapath
	vethwepl5dfc376
	vethwepl87ebe60
	vethwepleb93e00
	vethweplf55b8f1
	vxlan-6784
	weave
)
for iface in ${IFACES[@]}
do
	tcpdump -w `dirname $0`/tcpdump-minikube_$iface.pcap -i $iface &
done

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

echo "Press enter to stop the capture..."
read
echo "Capture stopped. Exiting..."
