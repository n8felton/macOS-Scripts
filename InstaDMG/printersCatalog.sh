#!/bin/bash

INSTADMG_ROOT="/instadmg"

exec > >(tee ${INSTADMG_ROOT}/AddOns/InstaUp2Date/CatalogFiles/printers.catalog ) 2>&1

BASE_URL="http://support.apple.com/downloads"
LOCALE="en_US"
CHECKSUM="${INSTADMG_ROOT}/AddOns/InstaUp2Date/checksum.py"

echo "Apple Updates:"

for i in 'DL894' 'DL899' 'DL1398' 'DL904' 'DL909' 'DL911' 'DL907' 'DL1496' 'DL903' 'DL910' 'DL1397' 'DL908' 'DL1495' 'DL902' 'DL905' 'DL906' 'DL912'
do
	FILE=$(curl --head --location --silent ${BASE_URL}/${i}/${LOCALE}/ | sed -En 's/^.*Location: (.*)$/\1/p' | tail -1 | tr -d '\r')
	${CHECKSUM} ${BASE_URL}/${i}/${LOCALE}/$(basename $FILE)
done
