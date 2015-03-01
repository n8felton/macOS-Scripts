#!/bin/sh
#
# Download and install the latest Munki2 tools from munkibuilds.org

cat <<EOF

**************************
** Munki auto-installer **
**************************

EOF
if [ "$(id -u)" -ne 0 ]; then
    echo "(Please enter your sudo password when prompted)"
    echo ""
fi

tmpdir=$(mktemp -d /tmp/munkibuilds-XXXX)
pkg_download="${tmpdir}/munki2.pkg"
echo "Grabbing the latest version..."
curl \
    -s \
    -o "${pkg_download}" \
    --connect-timeout 30 \
    https://munkibuilds.org/munkitools2-latest.pkg

sudo /usr/sbin/installer -pkg "${pkg_download}" -target /
