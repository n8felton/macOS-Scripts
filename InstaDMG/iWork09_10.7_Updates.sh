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
# Description:	Uses InstaDMG's "checksum.py" utility to generate a iWork09_Updates.catalog file
# 				for use with the InstaUp2Date AddOn.

BASE_URL="http://support.apple.com"
LOCALE="en_US"
CHECKSUM="/instadmg/AddOns/InstaUp2Date/checksum.py"
DATE=$(date "+%Y-%m-%d")
OUTPUT="$(PWD)/CatalogFiles/iWork09_10.7_Updates.catalog"

exec > >(tee "${OUTPUT}" ) 2>&1

echo "# Generated: $DATE"
echo "# \$Rev\$ from \$Date\$"
echo "Apple Updates:"

for i in DL1563
do
	TITLE=$(curl --silent ${BASE_URL}/kb/${i} | sed -En 's:<title>(.*)</title>:\1:p')
	FILE=$(basename $(curl --head --location --silent ${BASE_URL}/downloads/${i}/${LOCALE}/ | sed -En 's/^.*Location: (.*)$/\1/p' | tail -1 | tr -d '\r') .dmg)
	${CHECKSUM} "${BASE_URL}/downloads/${i}/${LOCALE}/${FILE}.dmg" | sed -E s/"$FILE"/"$TITLE"/
done
