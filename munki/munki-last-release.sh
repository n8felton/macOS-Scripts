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
pkg_download="${tmpdir}/munki-last-releases.pkg"
latest_stable_release=$(curl -s https://api.github.com/repos/munki/munki/releases | /usr/bin/ruby -e 'require "json"; puts JSON.parse(STDIN.read)["assets"][0]["browser_download_url"];')
echo "Grabbing the last version posted to GitHub Releases (includes Prereleases)..."
curl \
	-s \
	-L \
	-o "${pkg_download}" \
	--connect-timeout 30 \
	"${latest_stable_release}"

sudo /usr/sbin/installer -pkg "${pkg_download}" -target /
