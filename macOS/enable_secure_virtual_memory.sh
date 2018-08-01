#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" 
	exit 1
fi

log() {
	/bin/echo "$1" | /usr/bin/tee >(logger -t "$(basename "$0")")
}

log "Enabling secure virtual memory."
/usr/bin/defaults write "/Library/Preferences/com.apple.virtualMemory" UseEncryptedSwap -bool TRUE
log "Use of encrypted swap space is enabled."
