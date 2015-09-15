#!/bin/bash
log() {
	/bin/echo "$1" | /usr/bin/tee >(logger -t "$(basename "$0")")
}

log "Checking if this computer is currently bound to AD..."
computer_account="$(dsconfigad -show | sed -En 's/Computer Account.* //p')"
if [[ -n $computer_account ]]; then
	verify_computer_account="$(dscl /Search read /Computers/${computer_account})"
	if [[ -n $verify_computer_account ]]; then
		ad_domain=$(dsconfigad -show | sed -En 's/Active Directory Domain.* //p')
		log "Computer is bound to $ad_domain"
		return 0
	else
		log "Computer appears to be bound, but we can not find it in AD"
		return 2
	fi
else
	log "Computer does not appear to be bound"
	return 1
fi