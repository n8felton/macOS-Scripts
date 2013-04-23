#!/bin/bash
# Copyright 2012 Nathan Felton
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# 	http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# Description:	Uses InstaDMG's "checksum.py" utility to generate a 10.8_vanilla.catalog file
# 				for use with the InstaUp2Date AddOn.

BASE_URL="http://support.apple.com"
LOCALE="en_US"
CHECKSUM="/instadmg/AddOns/InstaUp2Date/checksum.py"
DATE=$(date "+%Y-%m-%d")
OUTPUT="$(PWD)/CatalogFiles/10.8_vanilla.catalog"

exec > >(tee "${OUTPUT}" ) 2>&1

echo "# Generated: $DATE"

cat <<'EOF'
# $Rev$ from $Date$

Installer Disc Builds:	12A269, 12B19, 12C54, 12D78

Output Volume Name:	Macintosh HD
Output File Name:	10.8_vanilla

OS Updates:
EOF
cat <<'EOF'
	iTunes 11.0.2	http://appldnld.apple.com/iTunes11/041-9794.20130220.DdPy6/iTunes11.0.2.dmg	sha1:e8eba6c2b83b9e24116a9944c808525bed260aa0
	Safari 6.0.4	http://swscan.apple.com/content/downloads/42/19/041-9948/ukb1udm7ie7zsfjc8o1lkzs8dcpax9d8gt/Safari6.0.4Mountain.pkg	sha1:ebcb909c0c9cc6a85a188cea2c2890724c1cbfe6
EOF
for i in DL1572 DL1628
do
	TITLE=$(curl --silent ${BASE_URL}/kb/${i} | sed -En 's:^.*<h1>(.*)</h1>$:\1:p' | tr / -)
	FILE=$(basename $(curl --head --location --silent ${BASE_URL}/downloads/${i}/${LOCALE}/ | sed -En 's/^.*Location: (.*)$/\1/p' | tail -1 | tr -d '\r') .dmg)
	${CHECKSUM} "${BASE_URL}/downloads/${i}/${LOCALE}/${FILE}.dmg" | sed -E s:"$FILE":"$TITLE":
done


