#!/usr/bin/python

import sys
import re
import optparse
import pprint
import os.path
import zipfile
import sqlite3
import FoundationPlist
import xml.etree.ElementTree as ET

from Foundation import NSData
from AppKit import NSBitmapImageRep, NSPNGFileType


def convertIconToPNG(icon_path, destination_path, desired_pixel_height=512):
    '''Converts an icns file to a png file, choosing the representation
    closest to (but >= if possible) the desired_pixel_height.
    Returns True if successful, False otherwise'''
    if os.path.exists(icon_path):
        image_data = NSData.dataWithContentsOfFile_(icon_path)
        bitmap_reps = NSBitmapImageRep.imageRepsWithData_(image_data)
        chosen_rep = None
        for bitmap_rep in bitmap_reps:
            if not chosen_rep:
                chosen_rep = bitmap_rep
            elif (bitmap_rep.pixelsHigh() >= desired_pixel_height and
                  bitmap_rep.pixelsHigh() < chosen_rep.pixelsHigh()):
                chosen_rep = bitmap_rep
        if chosen_rep:
            png_data = chosen_rep.representationUsingType_properties_(
                NSPNGFileType, None)
            png_data.writeToFile_atomically_(destination_path, False)
            return True
    return False


def get_payloadinfo(path, adobe_code):
  query = "SELECT value \
      FROM payloaddata \
      WHERE payloadid = '{0}' \
      AND key = 'PayloadInfo'".format(adobe_code)
  conn = sqlite3.connect(path)
  with conn:
    cur = conn.cursor()
    cur.execute(query)
    data = cur.fetchone()[0].encode('utf-8')

  return data


def get_source(path, app_info):
  query = "SELECT source "\
          "FROM InstallFile "\
          "WHERE destination = '{0}'".format(app_info)
  conn = sqlite3.connect(path)
  try:
    with conn:
      cur = conn.cursor()
      cur.execute(query)
      data = cur.fetchone()[0].encode('utf-8')
      return data
  except sqlite3.OperationalError:
    pass


def main():
  dirpath = os.path.dirname(os.path.realpath(sys.argv[0]))
  opt = optparse.OptionParser()
  opts, args = opt.parse_args()

  # pprint.pprint(args[0])
  tree = ET.parse(args[0])

  output_location = tree.find(".//OutputLocation").text
  package_name = tree.find(".//PackageName").text

  root = tree.getroot()
  adobe_codes = {}
  target_names = {}
  product_names = {}

  media_list = tree.findall(".//Media")
  for media in media_list:
    if 'adobeCode' in media.find(".//DeploymentInstall//Payload").keys():
      product_name = media.find(".//prodName").text
      # Remove the () around the year in the product name: (2015) -> 2015
      # product_name = re.sub('[()]', '', product_name)
      # Remove the spaces and year from the name.
      # This should help match Munki item names
      product_name = re.sub('[()\s\d]', '', product_name)
      target_folder = media.find("TargetFolderName").text
      # adobe_code = media.find(".//mediaSignature").text
      adobe_code = media.find(".//DeploymentUninstall//Payload").attrib[
          'adobeCode']
      # print target_folder, adobe_code
      target_name = media.find(".//IncludedPayloads//Payload/[AdobeCode='{0}']"
                               .format(adobe_code)).findtext('TargetName')
      print "{0},{1},{2}".format(product_name, target_folder, adobe_code)
      adobe_codes[target_folder] = adobe_code
      target_names[target_folder] = target_name
      product_names[target_folder] = product_name

  for target_folder, adobe_code in adobe_codes.iteritems():
    media_db = "{0}/{1}/Build/{2}_Install.pkg/Contents/Resources/Setup/{3}"\
        "/payloads/{4}/Media_db.db".format(
            output_location,
            package_name,
            package_name,
            target_folder,
            target_names[target_folder])
    install_db = "{0}/{1}/Build/{2}_Install.pkg/Contents/Resources/Setup/{3}"\
        "/payloads/{4}/Install.db".format(
            output_location,
            package_name,
            package_name,
            target_folder,
            target_names[target_folder])
    zip_file = "{0}/{1}/Build/{2}_Install.pkg/Contents/Resources/Setup/{3}"\
        "/payloads/{4}/{4}.zip".format(
            output_location,
            package_name,
            package_name,
            target_folder,
            target_names[target_folder])

    payloadinfo = ET.fromstring(get_payloadinfo(media_db, adobe_code))
    applaunch_path = payloadinfo.find(".//AppLaunch").attrib['path']
    app_contents = "{0}Contents".format(
        applaunch_path.split('Contents')[0])
    app_info = "{0}/Info.plist".format(app_contents)
    source = get_source(install_db, app_info)

    if source is not None:
      head = source.split('/')[0].strip("[]").split('_')[1].title()
      tail = source.split('/', 1)[1]
      info_plist = "{0}/{1}".format(head, tail)
      with zipfile.ZipFile(zip_file) as zip:
        plist = FoundationPlist.readPlistFromString(zip.read(info_plist))
        icon_file = plist.get('CFBundleIconFile')

        icon_path = "{0}/Resources/{1}".format(app_contents, icon_file)
    if not icon_path.endswith('.icns'):
      icon_path = icon_path + '.icns'

    icon_source = get_source(install_db, icon_path)
    if icon_source is not None:
      head = icon_source.split('/')[0].strip("[]").split('_')[1].title()
      tail = icon_source.split('/', 1)[1]
      icon_path = "{0}/{1}".format(head, tail)
      icon_icns = "{0}.icns".format(product_names[target_folder])
      icon_png = "{0}.png".format(product_names[target_folder])
      icns_dest = os.path.join(dirpath, 'icons', icon_icns)
      png_dest = os.path.join(dirpath, 'icons', icon_png)
      with zipfile.ZipFile(zip_file) as zip:
        with open(icns_dest, 'wb') as f:
          f.write(zip.read(icon_path))

      convertIconToPNG(icns_dest, png_dest)

if __name__ == '__main__':
    main()
