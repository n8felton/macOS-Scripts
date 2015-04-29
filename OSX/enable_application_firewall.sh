#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 
	exit 1
fi

log() {
	/bin/echo "$1" | /usr/bin/tee >(logger -t "$(basename "$0")")
}

if [ $(/usr/bin/defaults read "/Library/Preferences/com.apple.alf" globalstate) -eq 0 ]; then
	log "Application firewall was disabled."
	/usr/bin/defaults write "/Library/Preferences/com.apple.alf" globalstate -int 1
	log "Application firewall is now enabled."

	# Reload the application firewall
	log "Application firewall is being reloaded."
	/bin/launchctl unload /System/Library/LaunchAgents/com.apple.alf.useragent.plist
	/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist
	/bin/launchctl load /System/Library/LaunchAgents/com.apple.alf.useragent.plist
	/bin/launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
else
	log "Application firewall is already configured."
fi
