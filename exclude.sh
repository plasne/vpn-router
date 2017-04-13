#!/bin/bash
filename="$1"

# create table (if it doesn't exist)
iptables -N exclude

# remove routing (if exists), just in case something goes wrong
iptables -D FORWARD -i br0 -j exclude

# clear tables
ip route flush table 301
iptables -F exclude

# read domains from file
while read -r domain || [[ -n "$domain" ]]
do

  # nslookup the IP addresses
  nslookup $domain | awk -F' ' 'NR>4 { print $3 }' | while read -r ip
  do

    # add the routes and firewall rules
    ip route add $ip/32 via 192.168.0.1 table 301
    iptables -A exclude -i br0 -o vlan2 -d $ip/32 -j ACCEPT

  done
done < "$filename"
                                                                                                    
# add RETURN to the iptables
iptables -A exclude -j RETURN

# add routing
iptables -I FORWARD -i br0 -j exclude