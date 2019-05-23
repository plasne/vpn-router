#!/bin/bash
filename="$1"

# create table (if it doesn't exist)
iptables -N exclude

# remove routing (if exists), just in case something goes wrong
iptables -D FORWARD -i br0 -j exclude
ip rule del prio 501 from all table 301

# clear tables
ip route flush table 301
iptables -F exclude

# add table
ip rule add prio 501 from all table 301

# read domains from file
while read -r entry || [[ -n "$entry" ]]
do

  # ignore if a comment
  comment=$(echo "$entry" | awk '/^#/')
  if [[ -z "$comment" ]]
  then

    # determine if it is a CIDR address or domain
    cidr=$(echo "$entry" | awk '{match($0,/([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\/([0-9]{1,2})/); cidr = substr($0,RSTART,RLENGTH); if (length(cidr) > 0) print cidr}')
    if [[ -z $cidr ]]
    then

      # nslookup the IP addresses
      nslookup "$entry" | awk '$1 ~ /^ *Name:/ {i=1;next} i > 0 {match($0,/([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})/); ip = substr($0,RSTART,RLENGTH); if (length(ip) > 0) print ip}' | while read -r ip
      do

        # add the routes and firewall rules
        ip route add $ip/32 via 192.168.0.1 table 301
        iptables -A exclude -i br0 -o vlan2 -d $ip/32 -j ACCEPT

      done

    else

      # add the routes and firewall rules
      ip route add $cidr via 192.168.0.1 table 301
      iptables -A exclude -i br0 -o vlan2 -d $cidr -j ACCEPT

    fi
  fi

done < "$filename"
                                                                                                    
# add RETURN to the iptables
iptables -A exclude -j RETURN

# add routing
iptables -I FORWARD -i br0 -j exclude
<<<<<<< HEAD
ip rule add prio 501 from all table 301
=======
>>>>>>> d27f8e1ca04f0e00a0bbe159e90182e3ae674864
