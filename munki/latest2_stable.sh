#!/bin/bash
#
# Based on script found at https://munkibuilds.org/latest2.sh
# Thanks to Tim Sutton

cat <<EOF

**************************
** Munki auto-installer **
**************************

EOF
if [[ $EUID -ne 0 ]]; then
	echo "(Please enter your sudo password when prompted)"
	echo ""
fi

tmpdir=$(mktemp -d /tmp/munkibuilds-XXXX)
pkg_download="${tmpdir}/munki2.pkg"
latest_stable_release=$(curl -s https://api.github.com/repos/munki/munki/releases | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["assets"][0]["browser_download_url"]')
echo "Grabbing the latest stable version from GitHub Releases..."
curl \
	-s \
	-L \
	-o "${pkg_download}" \
	--connect-timeout 30 \
	"${latest_stable_release}"
	
sudo /usr/sbin/installer -pkg "${pkg_download}" -target /
