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
# Description:	Uses InstaDMG's "checksum.py" utility to generate a 10.6_vanilla.catalog file
# 				for use with the InstaUp2Date AddOn.

BASE_URL="http://support.apple.com"
LOCALE="en_US"
CHECKSUM="/instadmg/AddOns/InstaUp2Date/checksum.py"
DATE=$(date "+%Y-%m-%d")
OUTPUT="$(PWD)/CatalogFiles/10.6_vanilla.catalog"

exec > >(tee "${OUTPUT}" ) 2>&1

echo "#Generated: $DATE"

cat <<'EOF'
# $Rev$ from $Date$

Installer Disc Builds:	10A432, 10B504, 10C540, 10D573, 10D575, 10F569

Output Volume Name:	Macintosh HD
Output File Name:	10.6_vanilla

OS Updates:
EOF

for i in DL1009 DL1550 DL1399 DL1532 DL1512 DL1526 DL1536
do
	TITLE=$(curl --silent ${BASE_URL}/kb/${i} | sed -En 's:^.*<h1>(.*)</h1>$:\1:p' | tr / -)
	FILE=$(basename $(curl --head --location --silent ${BASE_URL}/downloads/${i}/${LOCALE}/ | sed -En 's/^.*Location: (.*)$/\1/p' | tail -1 | tr -d '\r') .dmg)
	${CHECKSUM} "${BASE_URL}/downloads/${i}/${LOCALE}/${FILE}.dmg" | sed -E s:"$FILE":"$TITLE":
done

cat <<'EOF'
	iTunes 10.6.3	http://appldnld.apple.com/itunes10/041-6244.20120611.bbhi8/iTunes10.6.3.dmg	sha1:e673e5cbd2955130efbc92a788fff178e66bd155
	Safari 5.1.7	http://appldnld.apple.com/Safari5/041-5476.20120509.oXWEO/Safari5.1.7SnowLeopard.dmg	sha1:32d1dca993b455bc5c230caef95ab70c702e6fee
EOF