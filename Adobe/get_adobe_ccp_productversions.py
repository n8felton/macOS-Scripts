#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re
import xml.etree.ElementTree as xml
from pprint import pprint

HOME = os.path.expanduser("~")
products = {}
products_cache_file = os.path.join(HOME,
                                   'Library/Application Support/Adobe/'
                                   'CCP/ProductsCache.xml')

products_cache_xml = xml.parse(products_cache_file)
root = products_cache_xml.getroot()

for product in root.findall('.//Product'):
    sap_code = product.attrib['sapCode']
    lang_set = product.attrib['langSet']
    version = product.attrib['version']
    path = product.find('path').text

    regex = r'{sap_code}/{lang_set}/(.*?)_(?:\d+_|{lang_set}).*$'.format(
            sap_code=sap_code,
            lang_set=lang_set)

    matches = re.search(regex, path)
    if matches:
        name = matches.group(1)

    products[name] = version

pprint(products)
