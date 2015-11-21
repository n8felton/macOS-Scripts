#!/bin/bash
# This script will rename all hostnames on the machine to match DNS.
# This script needs to be run as root (uid=0).
if [ $EUID -ne 0 ]; then
	echo "Must run as root!"
	exit 1
fi

# Find an active network interface
interface=$(route get 0.0.0.0 2>/dev/null | awk '/interface: / {print $2}')

# Obtain the computer's IP address.
ipAddress=$(ipconfig getifaddr ${interface})

# Flush DNS
case "$OSTYPE" in
	darwin14)
		which discoveryutil && discoveryutil mdnsflushcache || killall -HUP mDNSResponder
		;;
	darwin10)
		dscacheutil -flushcache
		;;
	*)
		killall -HUP mDNSResponder
		;;
esac

# Obtain the IP address's associated DNS name, and trim the trailing dot.
dnsHostname=$(dig -x $ipAddress +short | sed 's/\.$//')

# Trim the DNS hostname down to the intended computer name.
computerName=$(echo $dnsHostname | cut -d. -f1)

# Rename the machine.
echo "$(hostname) will be renamed to \"$computerName\" ($dnsHostname)"
hostname $dnsHostname
scutil --set HostName $dnsHostname
scutil --set ComputerName $computerName
scutil --set LocalHostName $computerName
