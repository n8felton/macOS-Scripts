#!/bin/bash
# This script will rename all hostnames on the machine to match DNS.
# This script needs to be run as root (uid=0).
if [ $EUID -ne 0 ]; then
	echo "Must run as root!"
	exit 1
fi

# Obtain the computer's IP address.
ipAddress=$(ipconfig getifaddr en0)

# Flush DNS
case "$OSTYPE" in
	darwin13)
                dscacheutil -flushcache;killall -HUP mDNSResponder
                ;;
        darwin1[1-2])
                killall -HUP mDNSResponder
                ;;
        darwin10)
                dscacheutil -flushcache
                ;;
        *)
        	discoveryutil udnsflushcaches
        	;;
esac

# Obtain the IP address's associated DNS name, and trim it.
dnsHostname=$(dig -x $ipAddress +short)

# Trim the DNS hostname down to the intended computer name.
computerName=$(echo $dnsHostname | cut -d. -f1)

# Rename the machine.
echo "$(hostname) will be renamed to \"$computerName\" ($dnsHostname)"
hostname $dnsHostname
scutil --set HostName $dnsHostname
scutil --set ComputerName $dnsHostname
scutil --set LocalHostName $computerName
