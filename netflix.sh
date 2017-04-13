#!/bin/bash

# create table (if it doesn't exist)
iptables -N netflix

# remove routing (if exists), just in case something goes wrong
iptables -D FORWARD -i br0 -j exclude
ip rule del prio 502 from all table 302

# clear tables
ip route flush table 302
iptables -F netflix

curl ipinfo.io/AS2906 | awk '{match($0,/([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\/([0-9]{1,2})/); ip = substr($0,RSTART,RLENGTH); if (length(ip) > 0) print ip}' |
while read -r cidr
do

  # add the routes and firewall rules
  ip route add $cidr via 192.168.0.1 table 302
  iptables -A netflix -i br0 -o vlan2 -d $cidr -j ACCEPT

done

# add RETURN to the iptables
iptables -A netflix -j RETURN

# add routing
iptables -I FORWARD -i br0 -j netflix
ip rule add prio 502 from all table 302