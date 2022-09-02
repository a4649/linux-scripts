#!/bin/sh
VM="XXX"
STATE="shut"
tmp=$(virsh list --all | grep " $VM " | awk '{ print $3}')
if [ "$tmp" == "$STATE" ]
then
    echo "$VM is in shutoff! Starting it..." 2>&1 | logger &
    /usr/bin/virsh start $VM 2>&1 | logger &
else
    echo "$VM is running! Skipping..."  2>&1 | logger &
fi
