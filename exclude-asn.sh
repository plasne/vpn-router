#!/bin/bash
asn="$1"
table="$2"
name="$3"
prio="$4"

# create table (if it doesn't exist)
iptables -N $name

# remove routing (if exists), just in case something goes wrong
iptables -D FORWARD -i br0 -j $name
ip rule del prio $prio from all table $table

# clear tables
ip route flush table $table
iptables -F $name

curl ipinfo.io/$asn | awk '{match($0,/([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\/([0-9]{1,2})/); cidr = substr($0,RSTART,RLENGTH); if (length(cidr) > 0) print cidr}' |
while read -r cidr
do

  # add the routes and firewall rules
  ip route add $cidr via 192.168.0.1 table $table
  iptables -A $name -i br0 -o vlan2 -d $cidr -j ACCEPT

done

# add RETURN to the iptables
iptables -A $name -j RETURN

# add routing
iptables -I FORWARD -i br0 -j $name
ip rule add prio $prio from all table $table