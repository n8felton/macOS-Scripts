#!/bin/sh
#
# Download and install the latest Munki2 tools from munkibuilds.org

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
choices_download="${tmpdir}/no_app.xml"
echo "Grabbing the latest version..."
curl \
    -s \
    -o "${pkg_download}" \
    --connect-timeout 30 \
    https://munkibuilds.org/munkitools2-latest.pkg
	
curl \
    -s \
    -o "${choices_download}" \
    --connect-timeout 30 \
    https://raw.githubusercontent.com/n8felton/Mac-OS-X-Scripts/master/munki/no_app.xml


sudo /usr/sbin/installer -applyChoiceChangesXML "${choices_download}" -pkg "${pkg_download}" -target /
