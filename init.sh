# add the custom route tables
ip rule add prio 500 from all table 300

# add the exclude jobs (4am and 5am daily)
cru a exclude "0 4 * * * sh /tmp/mnt/Lexar/exclude.sh /tmp/mnt/Lexar/exclude.txt"
cru a netflix "0 5 * * * sh /tmp/mnt/Lexar/netflix.sh"