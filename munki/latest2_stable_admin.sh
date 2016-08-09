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
choices_download="${tmpdir}/admin.xml"
latest_stable_release=$(curl -s https://api.github.com/repos/munki/munki/releases/latest | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["assets"][0]["browser_download_url"]')
echo "Grabbing the latest version..."
curl \
	-s \
	-L \
	-o "${pkg_download}" \
	--connect-timeout 30 \
	"${latest_stable_release}"

curl \
	-s \
	-o "${choices_download}" \
	--connect-timeout 30 \
	https://raw.githubusercontent.com/n8felton/Mac-OS-X-Scripts/master/munki/admin.xml

sudo /usr/sbin/installer -applyChoiceChangesXML "${choices_download}" -pkg "${pkg_download}" -target /
