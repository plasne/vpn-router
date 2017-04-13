# VPN Router

## Why you need a VPN

With recent changes to online privacy and a relaxing of regulations, internet users in the US no longer have a reasonable expection of privacy when using the internet. I will probably write more on this later, but for now I will just link to some articles by the EFF:

* https://www.eff.org/deeplinks/2017/04/trump-signs-bill-roll-back-privacy-rules-law 
* https://www.eff.org/deeplinks/2017/03/five-ways-cybersecurity-will-suffer-if-congress-repeals-fcc-privacy-rules 
* https://www.eff.org/deeplinks/2017/03/three-myths-telecom-industry-using-convince-congress-repeal-fccs-privacy-rules 

A very simple definition of a VPN is it creates an encrypted tunnel that your traffic goes through so your ISP cannot see what you are doing online - they will see that you are using a VPN service. It is very important to understand that you VPN provider will be able to see your traffic (so HTTPS, TOR, etc. are still relevant), but at least you get to choose now (you probably only have 1-2 ISPs offering broadband service in your area but there are hundreds of viable VPN providers).

Another popular use of VPNs is to get around geo-restrictions, because your traffic is coming out of whatever data center you select and most VPNs operate in dozens of countries, you can use services that only work in places on the globe (streaming video contracts often dictate that content is only available in certain places). While this might be an added benefit, it was not my reason for deploying a VPN so I have not devoted any time to getting this right and this article won't address this. It should be obvious, but just in case, no matter how much encyption or anonymity your tools might provide, if you log into a service, that service provider knows what you are doing, so keep that in mind. 

## Why a VPN router

You can run a VPN client on just about any modern computer, tablet, or phone, but there are some reasons to consider a router that tunnels all your connections through it automatically:

* Very few IoT devices can use a VPN client, many of them probably don't matter, but if the device has information you would rather keep private.
* iOS devices don't keep a VPN connection active when the device is on standby. While in most cases you can configure to reconnect automatically, the connection can vary from a second to almost a minute.
* Mobile devices that can hold a VPN connection open will drain some power doing so.

# Complications of a VPN

It would be great if this were as simple as all your devices use a VPN all the time, all services worked exactly the same way, all of the benefits and none of the pain. Sadly this isn't the case, using a VPN is an added piece of technology that has all the baggage that accompanies many security tools. Some of the things to be aware of:

* Not all services work through a VPN, for instance, Bank of America and Netflix.
* Many services will warn that the traffic is unusual (your IP says your in Europe and accessing a bank in the US for instance), and you will need to provide addition validation.
* Your devices might be able to get internet services from a variety of places (cell, multiple wifi, etc.), make sure you know how you are connected.
* Latency can be a problem since most of the places you would want to exit from are far away from the US.

## Considerations for a VPN provider

As I described it above, you are moving your trust from your ISP to your VPN provider, so you need to take some care in that decision, for me the criteria was:

* They must be headquartered in a "safe" country (one without pervasive surveillance, no data retention requirements, and one that challenge the US/EU governments).
* They must provide servers in "safe" countries.
* They must have a policy of strict no-logging and no-monitoring.
* They must be willing to shutdown servers rather than comply with activities that violate their policies.
* They must provide OpenVPN connectivity (ensures any devices can leverage the VPN).
* They must provide unlimited bandwidth and reasonably fast servers.

Some helpful links include:

* https://torrentfreak.com/anonymous-vpn-service-provider-review-2015-150228/ 
* https://en.wikipedia.org/wiki/Internet_censorship_and_surveillance_by_country

I chose NordVPN (http://nordvpn.com) because they met my requirements and had a few other bonuses:
* A mobile app with a kill switch for iOS.
* Enhanced security options such as double-VPN and TOR-over-VPN.
* 2048 bit encryption.

## What do you need beyond a VPN

A VPN alone isn't quite enough for online privacy, and this is a much larger topic, but for now I will link to a few other tools that I use:

* Privacy Badger (cookie blocker; anti-tracker) - https://www.eff.org/privacybadger 
* Avira Anti-Virus (anti-virus; anti-tracker) - https://www.avira.com/ 
* HTTPS Everywhere (uses HTTPS if available) - https://www.eff.org/https-everywhere 
* LastPass (password manager) - https://www.lastpass.com/ 
* Canvas Defender (anti-canvas fingerprint) - https://multiloginapp.com/canvasdefender-browser-extension/ 
* Random Agent Spoofer (agent spoofer) - https://addons.mozilla.org/en-US/firefox/addon/random-agent-spoofer/ 

There is no such thing as perfect security, but if you want the best you can get, look at:
* Tails (TOR + OS bundle) https://tails.boum.org/

## Choice of router

There are 3 main options for firmware on a VPN router: DD-WRT, TomatoUSB, OpenWrt. I only tried TomatoUSB, so I cannot comment on the others.

I chose the ASUS RT-AC3200 router, mostly because it had 3 radios and a 1.0Ghz dual-core processor. Less expensive options probably work fine too.

I purchased this router from flashrouters.com so that it came pre-installed with TomatoUSB, but I did have to upgrade the firmware to the latest version.

## Desired configuration

My desired configuration consisted of the following:

* 2 subnets, 1 on VPN and 1 without
* Routing between the subnets so devices on each could talk to each other
* 2 WiFi SSIDs, 1 for VPN and 1 for clear
* At least 1 5GHz radio and 1 2.4GHz radio for each
* A way to connect to specific services without VPN even when in the VPN subnet

I was able to achieve everything I wanted in that configuration, but it was a lot of work and research. This guide will walk you through how to configure the same thing, and hopefully give you a good enough understanding of the system that you could configure things any way you like.

## Multiple subnets

As mentioned, I wanted to have 2 different subnets:

* 192.168.11.0/24 which uses VPN
* 192.168.12.0/24 which goes unchanged to the Internet

The subnets can be easily created on the Basic / Network tab:

![LAN](/images/lan.png)

Make sure you save. Then you need to head over to Advanced / LAN Access to make sure traffic can route between the 2 subnets:

![LAN Access](/images/lan-access.png)

Again, make sure you save.

Note: traffic between the subnets will only be allowed when VPN Tunneling is not started, but more on how to solve that later.

## Mapping physical ports to the subnets

Now that the networks are setup, you need to map the physical ports to the proper subnets. If you aren't using any wired devices, you can skip this part.

On the Status / Overview tab you can see the physical ports state (speed, duplex, etc.), and you want to see whether those are in the correct order or inverted (mine were inverted).

![Port State](/images/port-state.png)

If they are inverted, you can click "Configure", which will take you to the Basic / Network tab and you can invert the port order:

![Port State Config](/images/port-state-config.png)

You must save the change if you make it. Sadly this change does not carry over to the VLAN configuration, which will still have your ports inverted, but at least you can see your traffic properly. Head over to Advanced / VLAN and you can map the ports (maybe):

![VLAN](/images/vlan.png)

Unfortunately, as of this writing, there is a bug with some chipsets (including mine) that wouldn't allow this port mapping to save properly, so if you have that problem (lines 1 and 2 reset after reboot, documented here: https://bitbucket.org/pl_shibby/tomato-arm/issues/94/assigning-ports-to-vlans-doesnt-work), you can configure it via the command line. To do that, go to Tools / System Commands and you can get a listing of your port configuration:

```bash
nvram show | grep vlan.ports
```

![Show Ports](/images/show-ports.png)

Then you can change it however you like. Note a few things:

* Port 0 is your WAN port.
* You will configure one more port than you have, I believe this is accepting the untagged traffic. This needs to be included in each line.
* One of the lines will need to have an * right after this untagged port to denote that it is the default VLAN for untagged traffic.

For my router, I had 4 ports and I wanted ports 1 and 2 to be on VLAN 3 and ports 3 and 4 to be on VLAN 1. But remember that my ports are inverted so I did this:

```bash
nvram set vlan1ports="1 2 5"
nvram set vlan2ports="0 5"
nvram set vlan3ports="3 4 5*"
nvram show | grep vlan.ports
nvram set manual_boot_nv=1
nvram commit
```

![Set Ports](/images/set-ports.png)

If what I wrote isn't clear, there is another article that explains it well: http://doodlebobbers.com/setting-vlan-ports-on-tomato-via-command-line/.

However you change the ports, you need to reboot the router for the change to take effect.

## Mapping WiFi radios to the subnets

The first thing you need to do is setup the radios to the proper SSIDs and security requirements. In the router I used, there were 2 5GHz radios and 1 2.4GHz radio. For my configuration, I decided I wanted all 3 of those radios to form my VPN network and I would use a different WAP to form my clear network. There is plenty of healthy debate online on whether you should use the same or different SSIDs when building a network out of several radios, but for practical manageability, I wanted a single SSID for my VPN network and a single SSID for my clear network. Of course this means all my radios have the same password as well.

A few things to consider:

* Higher frequencies carry more data but have shorter range and less penetrating power.
* Auto for channel is a good place to start, but it didn't work for one of the radios. There is a Scan feature that can show you where there are other devices in the band, and you can pick something free.
* Higher channel widths carry more data.

You can configure the radios on the Basic / Network tab:

![Radios](/images/radios.png)

You might also consider increasing the transmit power of the radios, which you can do in Advanced / Wireless. I chose to raise all 3 of my radios to to 168mW from 42mW. This provided some boost to signal quality, though not much.

On the Status / Overview tab you can see how you did:

![Radio Overview](/images/radio-overview.png)

On the Status / Device List tab, you can test the Noise Floor and see the RSSI and Quality numbers for your devices. There are 
several things to consider here:

* You want a Noise Floor that is around -100dBm.
* You want your devices to be much greater than that, so -30dBm would be great.
* The difference between those numbers is going to factor into your Quality level because you that gap so that what is being received is data and not noise.
* You can also see on this page which radio your devices are connected to.

On the Advanced / VLAN tab, you can configure which radios go to which LAN (what I was referring to as subnets earlier). Since all 3 of my radios are going to form my VPN network, I am OK to leave all those on LAN (br0), which is my 192.168.11.0/24 subnet.

![Wireless Bridge](/images/wireless-bridge.png)

## Bridging more radios

My main router only had 1 2.4GHz radio and unfortunately the 5GHz radios do not cover a lot of my house. That meant I needed at least another 2.4GHz radio to form my clear network. I had a Apple AirPort Time Capsule, so I decided to use that.

It was plugged into my ASUS router on a port that was mapped to (LAN1 / VLAN3 / br1) and configured so that the AirPort would get its configuration by DHCP. This is important, because if you remember the subnet setup, my ASUS router is running a DHCP server in that network and it will pass out the appropriate DHCP scope options (including DNS).

![AirPort Internet](/images/airport-internet.png)

It was configured to present its own network (using both the 5GHz and 2.4GHz radios).

![AirPort Wireless](/images/airport-wireless.png)

For those doing exactly this configuration, there is another problem - the Time Capsule was now on a different subnet than the Mac that needed to use it, so the AirPort Utility cannot find it. In the AirPort Utility you can still manage it by going to File / Configure Other and specifying the IP address and password. To backup to it, you need to go into Finder and then to Go / Connect to Server and specify your name, server address (afp://<ipaddress>), and password.

![Finder Connect](/images/finder-connect.png)

In Time Machine, you can then select the disk:

![Time Machine Connect](/images/timemachine-connect.png)

## VPN Tunneling

Now that your networks and devices are all working, lets configure the VPN tunnel. Go to VPN Tunneling / OpenVPN Client and configure per your VPN instructions. I will show my configuration below and then discuss the relevant points.

![OpenVPN Basic](/images/openvpn-basic.png)

![OpenVPN Advanced](/images/openvpn-advanced.png)

![OpenVPN Keys](/images/openvpn-keys.png)

![OpenVPN Routing Policy](/images/openvpn-routingpolicy.png)

The things to be aware of:

* You want to "Start with WAN" so that your tunnel comes back up whenever your router reboots.
* You want to "Create NAT on tunnel" otherwise you must configure routing manually (which you are going to have to do some anyway, but this gets it started).
* You need to "Ignore Redirect Gateway" so that the routes provided by the OpenVPN tunnel are not applied. If you don't select this, the routes are going to force all your traffic over the VPN and you want to apply that to only 1 network.
* I added the "keepalive 10 60" setting so that there is always traffic and the tunnel stays connected.
* You will get the keys from your VPN provider and they need to match the IP address of the server you are connecting to.
* In Routing Policy you are selecting what will be redirected over VPN. There is no interface to bypassing the VPN, but I will show that later.

After saving, you need to Start the tunnel. At this point, all the traffic from the 192.168.11.0/24 network is being routed over VPN and I was not able to get to my 192.168.12.0/24 network from the 11 network.

## Plugging the DNS leak

I believe it is common that the DNS servers are provided by the OpenVPN configuration so that your clients will connect to a DNS server that is close to where the tunnel exits, this is both efficient and more anonymous (you no longer have a DNS entry close to your computer but close to the tunnel exit further masking your real location). NordVPN does this.

Unfortunately, when we turned on "Ignore Redirect Gateway" it added an OpenVPN configuration setting of route-nopull which means the routing information for DNS didn't flow down, but we can add our own. Go to Advanced / DHCP/DNS and add a custom Dnsmasq configuration:

```bash
dhcp-option=tag:br0,option:dns-server,###.###.###.###,###.###.###.###
```

![Dnsmasq](/images/dnsmasq.png)

Replace ###.###.###.### with the IP addresses of your desired DNS servers. Save again. NordVPN offers DNS on the same IP address as the VPN exit node, so that is an option. Alternatively you could consider something like the OpenNIC Project (https://www.opennicproject.org/) or any other DNS provider that you trust. However, I will say again, you don't want to use an autocast server, while that gets you the lowest latency by placing the server near you, that works against the goal of masking your traffic.

You will notice this is tagged to apply only to the br0 subnet, so devices on br1 will get something different. You could define it here, but there are some GUI options for this, so let's use that. Go to Basic / Network and look at the WAN Settings:

![WAN Settings](/images/wan-settings.png)

The DNS Server is set to "Auto", which supplies the Google DNS servers (8.8.8.8 and 8.8.4.4). You could change this to "Manual" and supply your own. Remember that because of the setting above, this is only going to apply to our clear network, so using an autocast DNS like Google should be fine. I did notice one other interesting thing though, which is it added the DNS options from my modem, you can see this on the Status / Overview tab:

![WAN Overview](/images/wan-overview.png)

It is a good idea to ensure the VPN clients can only access the specified DNS server, that way they don't have a local configuration option that causes a DNS leak by using an autocast or local server. To do that, go to Administration / Scripts / Firewall and put in the following:

```bash
iptables -I FORWARD -i br0 -p udp --dport 53 -j DROP
iptables -I FORWARD -i br0 -p tcp --dport 53 -j DROP
iptables -I FORWARD -i br0 -p udp --dport 53 -d ###.###.###.### -j ACCEPT
iptables -I FORWARD -i br0 -p tcp --dport 53 -d ###.###.###.### -j ACCEPT
iptables -I FORWARD -i br0 -o vlan2 -j DROP
```

The first 2 lines instruct the router to drop all packets it would forward to port 53 (DNS) over both UDP and TCP. The next 2 lines instruct the router to allow all packets it would forward to port 53 over both UDP and TCP that is bound for a specific IP address (the IP address of the desired VPN DNS server). If you have more than one DNS server you supplied to Dnsmasq, add those as new pairs of lines after line 4. The section on Kill Switch will address what line 5 does.

You need to save and these settings won't take effect until you reboot the router. You need to reboot before this next section, so do that now.

The order of these rules is important, the first rule that the system comes across it will stop processing and enact that rule, so it might at first seem odd that we are dropping all the traffic before we are accepting it. Well, in fact we aren't because the rules are going to be entered in reverse order. The -I flag is INSERTing the rule into the FORWARD table and because we didn't specify a position, it is inserting it at the top. To see that, go to Tools / System Commands and execute the following:

```bash
iptables -S FORWARD
```

![iptables FORWARD](/images/iptables-forward.png)

You should observe a few things:

* The -P rule is the default rule (if nothing else is processed, do this) which should be DROP.
* All traffic to our vlan2 (which is our WAN, our clear internet traffic) is dropped from the VPN network (more on that later).
* Our DNS server IPs are ACCEPTed for port 53 traffic.
* Then all other port 53 traffic is DROPPed.
* Finally, everything going to tun11 (which is our VPN tunnel) is ACCEPTed.

You should now test your connection and the settings we have applied by doing a few things. First, on a computer connected to the VPN, go to http://ipleak.net and see if your IP address is showing the exit node for your VPN and DNS address showing whatever you set that to:

![ipleak.net](/images/ipleak-net.png)

We will discuss how to block WebRTC later, but at least make sure the IP address and DNS are right. Next, we need to make sure that this is the only DNS server we can contact, so open up a command prompt on the same client computer and type:

```bash
nslookup
```

Then make sure your DNS server selection(s) are set properly being passed to this client by typing:

```bash
server
exit
```

You should see that only the correct DNS server(s) are returned. Next you can verify that you cannot get to other DNS servers by typing:

```bash
telnet 8.8.8.8 53
```

You should timeout eventually because the connection couldn't be made. Of course you should be able to connect to the DNS server(s) you chose. If you are using Windows, the Telnet client is not installed by default so you will need to install that (it is a Windows Feature). Here is what the entire exchange should look like:

![bash test DNS](/images/bash-test-dns.png)

## The kill switch

The steps to implement the kill switch were applied when we created the DNS rules for the firewall script above, however, I wanted to make this a section because it is a very important rule. The rule should look like this:

```bash
iptables -I FORWARD -i br0 -o vlan2 -j DROP
```

This rule states that any traffic that would forward from br0 (VPN subnet) to vlan2 (WAN, internet) should be dropped. Any rules that are going to route around the VPN would need to come before this rule (which is to say they need to be placed after it since the order will be inverted), but more on that later.

## Routing between subnets

Before we added and started the VPN tunnel, we could route between the 192.168.11.0/24 subnet and 192.168.12.0/24 subnet, but now we cannot route to the 12 subnet from the 11 subnet because our traffic is being hijacked by the VPN tunnel. To see what is causing that, we need to go to Tools / System Commands and:

```bash
ip rule show
echo " "
ip route show table 311
echo " "
ip route show table main
```

![ip rule and ip route 311](/images/iprule-iproute311.png)

This will show the rules so we can see what routing is applied. We see that the local routing table is applied, then a custom table of 311 (which only applies to things marked 0x137, which is our br0 subnet), then our main table, and finally our default table. If we look at table 311 it only has 1 rule, route everything over the VPN tunnel (tun11). If we look at our main table, we see that the routing between our subnets is there. The problem is we will never get to the main table because our traffic is going to go out the tun11 device first.

What we need to do is create our own custom routing table that puts the routing between our subnets at a lower priority number (applied first). To do this, we need to go to Administration / Scripts / Init and add:

```bash
ip rule add prio 500 from all table 300
```

Save and then go to Administration / Scripts / Firewall and add the routes to table 300:

```bash
ip route add 192.168.12.0/24 dev br1 table 300
ip route add 192.168.11.0/24 dev br0 table 300
```

Save and reboot. After the reboot, we can check to make sure our changes were applied by going to Tools / System Commands and running:

```bash
ip rule show
echo " "
ip route show table 300
```

![ip rule and ip route 300](/images/iprule-iproute300.png)

From a client computer you should be able to route between the subnets now.

## Excluding specific domains from VPN

I use Bank of America, which unfortunately doesn't allow a VPN to be used to access their site. I will probably find other examples like this, so I created a script that can run when the firewall is started and then once a day and put special routing rules for a list of domains that bypass the VPN.

To do this, we first need a place to store the scripts. There are variety of options:

* You could store in the flash memory of the router (search for JFFS for information on how to do that), but then you have to put the files back out there every time you upgrade the router.
* You could store them on a website somewhere, but since these are firewall rules, I wasn't excited about that option.
* You could store them on a CIFS share, but I don't keep a server running anywhere.
* You could store them on USB, that's what I did because I had a small USB thumbdrive sitting around.

For the USB, just plug it in, and then go to USB and NAS / USB Support and click Refresh to see it. It will even show you the name it mounted it under:

![USB](/images/usb.png)

Easy enough, now you can put the exclude.sh script I have here on GitHub on your storage. You then need to create a file that simply contains on separate lines what you want to filter (exclude.txt is an example):
* domain name, ex. bankofamerica.com
* CIDR address, ex. 111.222.333.0/24
* # for comments

To discover what you need to exclude, there are a variety of tools:
* You can go to the site with devtools on in the browser and look at what was called.
* You can use nslookup to see what the IP addresses for a domain name are.
* You can use http://ipinfo.io/<ASN#> to get IP address blocks of ASN #s (more on that later).
* You can monitor the traffic going through your router at Status / Web Usage.
  * Unfortunately, this only logs HTTP traffic, but you can get the domains that were called by going to Advanced / DHCP/DNS and adding the line log-queries to the Dnsmasq. Once you do that, you will see the DNS requests in your Status / Logs.

## Excluding a whole ASN of CIDR addresses

The previous method works well if there are a handful of addresses or CIDR ranges that you need to exclude, but in the case of Netflix, there are hundreds of CIDR ranges, so I wrote another script called exclude-asn.sh and included it here. Again, you can put it on your storage and then run:

```bash
sh exclude-asn.sh AS2906 302 netflix 502
```

This will query http://ipinfo.io/AS2906 and get all the Netflix CIDR ranges and create the necessary bypass rules for them. In the above example, "302" is the ip route table that will be created, "netflix" is the iptable that will be created, and "502" is the priority in ip rule.

The easiest way I found to get the ASN is to do an nslookup on a domain, get the IP address, go to http://ipinfo.io/<ipaddress> and it will show you the ASN.

To back out all those changes, you can run:

```bash
sh delete-asn.sh AS2906 302 netflix 502
```

## Scheduling exclusion updates

If you have any domain names or if the CIDR address ranges change from time to time, you will need to schedule the rebuilding of those rules. You can do that with a cron job, simply go to Administration / Scripts and add something like:

```bash
cru a exclude "0 4 * * * sh /tmp/mnt/Lexar/exclude.sh /tmp/mnt/Lexar/exclude.txt"
cru a netflix "0 5 * * * sh /tmp/mnt/Lexar/exclude-asn.sh AS2906 302 netflix 502"
```

TomatoUSB uses cru for scheduling cron jobs. This tells the exclude job to run at 4am and the netflix job to run at 5am each day. The scripts simply simply overwrite the rules so you can run them whenever.

To get status information about your cron jobs, you need to enable them to go to your log in Administation / Logging:

![cron logging](/images/cron-logging.png)

Once you enable that, the log messages should show up in Status / Logs the next time it runs.

## Blocking WebRTC

The good news is if you do nothing to block WebRTC, as long as you going through the router VPN, it won't matter because the IP address that is given out will be an internal IP. However, I would still recommend blocking WebRTC for those times you aren't on VPN.

* Firefox: browse to "about:config" and set "media.peerconnection.enabled" to "false".
* Chrome: browse to "about:flags" and set "WebRTC Stun origin header" to "disabled".

If those don't work, there are plenty of browser extensions that block WebRTC.
