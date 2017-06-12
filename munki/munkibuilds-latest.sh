#!/bin/sh
#
# Download and install the latest version of Munki tools from munkibuilds.org

cat <<EOF

*********************************
** Munkibuilds auto installer  **
*********************************

EOF
if [[ $EUID -ne 0 ]]; then
    echo "(Please enter your sudo password when prompted)"
    echo ""
fi

tmpdir=$(mktemp -d /tmp/munkibuilds-XXXX)
pkg_download="${tmpdir}/munki3.pkg"
echo "Grabbing the latest version..."
curl \
    -s \
    -o "${pkg_download}" \
    --connect-timeout 30 \
    https://munkibuilds.org/munkitools3-latest.pkg

sudo /usr/sbin/installer -pkg "${pkg_download}" -target /
