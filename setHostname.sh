#!/bin/bash
# This script will rename all hostnames on the machine to match DNS.
# This script needs to be run as root (uid=0).
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 
	exit 1
fi

# Find an active network interface
interface=$(route get 0.0.0.0 2>/dev/null | awk '/interface: / {print $2}')

# If ${interface} wasn't set, we probably don't have an internet connection
# Exit now because we're not going to talk to DNS like this.
if [[ -z "${interface}" ]]; then
  exit 1
fi

# Obtain the computer's IP address.
ip_address=$(ipconfig getifaddr ${interface})

# Flush DNS
case ${OSTYPE} in
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
dns_hostname=$(dig +short -x ${ip_address})
dns_hostname=${dns_hostname%.}

# If we were not able to find DNS record, use the current hostname.
if [[ -z ${dns_hostname} ]]; then
  dns_hostname=$(hostname)
fi

# Trim the DNS hostname down to the intended computer name and make ALL CAPS.
computer_name=$(echo ${dns_hostname%%.*} |tr "[:lower:]" "[:upper:]")

# Rename the machine.
#echo "$(hostname) will be renamed to \"${computer_name}\" (${dns_hostname})"
echo -e "Old Hostname : \033[31m$(hostname)\033[0m"
echo -e "Computer Name: \033[32m${computer_name}\033[0m"
echo -e "DNS Hostname : \033[32m${dns_hostname}\033[0m"
hostname "${dns_hostname}"
scutil --set HostName "${dns_hostname}"
scutil --set ComputerName "${computer_name}"
scutil --set LocalHostName "${computer_name}"
