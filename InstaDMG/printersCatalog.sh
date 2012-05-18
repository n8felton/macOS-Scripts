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
# Description:	Uses InstaDMG's "checksum.py" utility to generate a printers.catalog file
# 				for use with the InstaUp2Date AddOn.

exec > >(tee $(PWD)/printers.catalog ) 2>&1

BASE_URL="http://support.apple.com/downloads"
LOCALE="en_US"
CHECKSUM="/instadmg/AddOns/InstaUp2Date/checksum.py"

echo "Apple Updates:"

for i in 'DL894' 'DL899' 'DL1398' 'DL904' 'DL909' 'DL911' 'DL907' 'DL1496' 'DL903' 'DL910' 'DL1397' 'DL908' 'DL1495' 'DL902' 'DL905' 'DL906' 'DL912'
do
	FILE=$(curl --head --location --silent ${BASE_URL}/${i}/${LOCALE}/ | sed -En 's/^.*Location: (.*)$/\1/p' | tail -1 | tr -d '\r')
	${CHECKSUM} ${BASE_URL}/${i}/${LOCALE}/$(basename $FILE)
done
