
# prevent DNS leak
iptables -I FORWARD -i br0 -p udp --dport 53 -j DROP
iptables -I FORWARD -i br0 -p tcp --dport 53 -j DROP
iptables -I FORWARD -i br0 -p udp --dport 53 -d ###.###.###.### -j ACCEPT
iptables -I FORWARD -i br0 -p tcp --dport 53 -d ###.###.###.### -j ACCEPT

# kill switch
iptables -I FORWARD -i br0 -o vlan2 -j DROP

# routing between subnets
ip route add 192.168.12.0/24 dev br1 table 300
ip route add 192.168.11.0/24 dev br0 table 300

# vpn bypass
sh /tmp/mnt/Lexar/exclude.sh /tmp/mnt/Lexar/exclude.txt
sh /tmp/mnt/Lexar/netflix.sh