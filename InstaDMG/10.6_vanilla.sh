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

echo "# Generated: $DATE"

cat <<'EOF'
# $Rev$ from $Date$

Installer Disc Builds:	10A432, 10B504, 10C540, 10D573, 10D575, 10F569

Output Volume Name:	Macintosh HD
Output File Name:	10.6_vanilla

OS Updates:
EOF

cat <<'EOF'
	iTunes 11.0.4	http://appldnld.apple.com/iTunes11/091-6058.20130605.Cw321/iTunes11.0.4.dmg	sha1:cd9f00b54f2c7b2b46083f8c3d2813e0b3bc3b30
EOF

for i in DL1569 DL1573 DL1399 DL1532 DL1512 DL1670 DL1536
do
	TITLE=$(curl --silent ${BASE_URL}/kb/${i} | sed -En 's:^.*<h1>(.*)</h1>$:\1:p' | tr / -)
	FILE=$(basename $(curl --head --location --silent ${BASE_URL}/downloads/${i}/${LOCALE}/ | sed -En 's/^.*Location: (.*)$/\1/p' | tail -1 | tr -d '\r') .dmg)
	${CHECKSUM} "${BASE_URL}/downloads/${i}/${LOCALE}/${FILE}.dmg" | sed -E s:"$FILE":"$TITLE":
done
