# netstat -ano --> 	All active TCP/UDP connections with owning PID — spot unexpected listeners or outbound connections
# arp -a --> IP of local nodes on the subnet
# route print --> Route table
# Get-DnsClientCache --> See recently resolved domains
# net use --> All mapped drives and UNC shares including credentials context — often reveals lateral movement paths
# Get-NetIPConfiguration -Detailed --> Interface info
# Get-SmbSession --> 

# Admin commands if elevated
#  HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles --> Get every network the node connected too
# get-NetTCPConnection
# netsh wlan show profiles
