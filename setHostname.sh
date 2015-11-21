#!/bin/bash
# This script will rename all hostnames on the machine to match DNS.
# This script needs to be run as root (uid=0).
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 
	exit 1
fi

# Find an active network interface
interface=$(route get 0.0.0.0 2>/dev/null | awk '/interface: / {print $2}')

# Obtain the computer's IP address.
ip_address=$(ipconfig getifaddr ${interface})

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
dns_hostname=$(dig -x ${ip_address} +short | sed 's/\.$//')

# Trim the DNS hostname down to the intended computer name.
computer_name=$(echo ${dns_hostname} | cut -d. -f1)

# Rename the machine.
echo "$(hostname) will be renamed to \"${computer_name}\" (${dns_hostname})"
hostname "${dns_hostname}"
scutil --set HostName "${dns_hostname}"
scutil --set ComputerName "${computer_name}"
scutil --set LocalHostName "${computer_name}"
