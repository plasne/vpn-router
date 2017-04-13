#!/bin/bash
asn="$1"
table="$2"
name="$3"
prio="$4"

# remove rule
ip rule del prio $prio from all table $table

# remove routes
ip route flush table $table

# remove iptables
iptables -D FORWARD -i br0 -j $name
iptables -F $name
iptables -X $name
