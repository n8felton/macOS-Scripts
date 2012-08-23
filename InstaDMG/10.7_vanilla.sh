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
# Description:	Uses InstaDMG's "checksum.py" utility to generate a 10.7_vanilla.catalog file
# 				for use with the InstaUp2Date AddOn.

BASE_URL="http://support.apple.com"
LOCALE="en_US"
CHECKSUM="/instadmg/AddOns/InstaUp2Date/checksum.py"
DATE=$(date "+%Y-%m-%d")
OUTPUT="$(PWD)/CatalogFiles/10.7_vanilla.catalog"

exec > >(tee "${OUTPUT}" ) 2>&1

echo "#Generated: $DATE"

cat <<'EOF'
# $Rev$ from $Date$

Installer Disc Builds:	11A511, 11B26, 11C74, 11D50, 11E53, 11E2702

Output Volume Name:	Macintosh HD
Output File Name:	10.7_vanilla

OS Updates:
EOF

for i in DL1515 DL1537 DL1564 DL1524
do
	TITLE=$(curl --silent ${BASE_URL}/kb/${i} | sed -En 's:^.*<h1>(.*)</h1>$:\1:p' | tr / -)
	FILE=$(basename $(curl --head --location --silent ${BASE_URL}/downloads/${i}/${LOCALE}/ | sed -En 's/^.*Location: (.*)$/\1/p' | tail -1 | tr -d '\r') .dmg)
	${CHECKSUM} "${BASE_URL}/downloads/${i}/${LOCALE}/${FILE}.dmg" | sed -E s:"$FILE":"$TITLE":
done

cat <<'EOF'
	Safari 6	http://swcdn.apple.com/content/downloads/41/52/041-6856/x5uvu03lvir18bqkzslxhh0prnly9oqoys/Safari6Lion.pkg	sha1:ba25da3f513f0535ee33bda23a1ce021cbad65d5
	iTunes 10.6.3	http://appldnld.apple.com/itunes10/041-6244.20120611.bbhi8/iTunes10.6.3.dmg	sha1:e673e5cbd2955130efbc92a788fff178e66bd155
	10.7.4 Supplemental Update	http://swcdn.apple.com/content/downloads/17/57/041-6014/hfBmdFTdwW9tmjbsYdfK9YbrJLPdVhdCNq/MacOSXUpd10.7.4Supp.pkg	sha1:ca5138ba9171c74e71408d4a93d8e9ffdaa84f5f
EOF
