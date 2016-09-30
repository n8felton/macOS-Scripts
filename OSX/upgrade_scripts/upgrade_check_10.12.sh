#!/bin/bash
# macOS 10.12 Sierra Upgrade
# 
# Prerequisites for this upgrade:
# http://arstechnica.com/apple/2016/09/macos-10-12-sierra-the-ars-technica-review/2/#h1
# - MacBook (late 2009 and later)
# - iMac (late 2009 and later)
# - MacBook Air (2010 and later)
# - MacBook Pro (2010 and later)
# - Mac Mini (2010 and later)
# - Mac Pro (2010 and later)

os_upgrade_name="macOS 10.12 Sierra"
os_upgrade_vers_major="12"

######################
# Check Operating System Version
######################
product_version=$(sw_vers -productVersion)
semver=( ${product_version//./ } )
os_vers="${semver[0]}"
os_vers_major="${semver[1]}"
os_vers_minor="${semver[2]}"
echo "Current OS:       ${os_vers}.${os_vers_major}.${os_vers_minor}"

if (( ${os_vers_major} >= 12 )) && (( ${os_vers} == 10 )) ; then
  echo "Current Operating System is already ${os_upgrade_name} or newer. Quitting."
  exit 1
fi

case ${os_vers_major} in
  ([7-9]|1[0-1])
    echo "Current Operating System is eligible for an upgrade to ${os_upgrade_name}."
    ;;
  *)
    echo "Unable to determine if your system is eligible for an upgrade to ${os_upgrade_name}"
    exit 1
    ;;
esac

# Check CPU Architecture
# Only 64-bit is Supported
hwcpu64bit=$(sysctl -n hw.cpu64bit_capable)
if [[ $hwcpu64bit ]]; then
  echo "64-bit processor detected."
else
  echo "64-bit processor not detected. Quitting."
  exit 1
fi

######################
# Check hardware model
######################
hwmodel=$(sysctl -n hw.model)
hwmodel_re='([[:alpha:]]*)([[:digit:]]*),([[:digit:]])'
if [[ $hwmodel =~ $hwmodel_re ]]; then
  hwmodel_name="${BASH_REMATCH[1]}"
  hwmodel_num="${BASH_REMATCH[2]}"
  hwmodel_rev="${BASH_REMATCH[3]}"
fi

# http://www.everymac.com/mac-answers/macos-sierra-faq/macos-sierra-1012-compatible-macs-system-requirements.html
# - iMac10,1
# - MacBook6,1
# - MacBookAir3,1
# - MacBookPro6,1
# - Macmini4,1
# - MacPro5,1

case "${hwmodel_name}" in
  iMac)
    min_hwmodel_num=10
    ;;
  MacBook)
    min_hwmodel_num=6
    ;;
  MacBookAir)
    min_hwmodel_num=3
    ;;
  MacBookPro)
    min_hwmodel_num=6
    ;;
  Macmini)
    min_hwmodel_num=4
    ;;
  MacPro)
    min_hwmodel_num=5
    ;;
  VMware)
    min_hwmodel_num=7
    ;;
esac

if (( ${hwmodel_num} >= ${min_hwmodel_num} )); then
  echo "Model Identifier: ${hwmodel}"
else
  echo "This computer does not meet the hardware model requirements for ${os_upgrade_name}. Quitting."
  exit 1
fi

######################
# Check system specs
######################
# RAM
hwmemsize=$(sysctl -n hw.memsize)
# 1024**3 = GB
ramsize=$(expr $hwmemsize / $((1024**3)))

if (( ${ramsize} >= 2 )); then
  echo "System Memory:    ${ramsize} GB"
  hwmemsize_pass=1
else
  echo "Less than 2GB of RAM detected. Quitting."
  exit 1
fi

# Disk Space
diskutil_plist="$(mktemp -t "diskutil").plist"
diskutil info -plist / > ${diskutil_plist}
freespace=$(defaults read "${diskutil_plist}" FreeSpace)
rm "${diskutil_plist}"
# 1024**3 = GB
freespace=$(expr $freespace / $((1024**3)))

if (( ${freespace} >= 9 )); then
  echo "Free Space:       ${freespace} GB"
else
  echo "Less than 9GB of free disk space detected. Quitting."
  exit 1
fi

echo "This computer has passed all checks and is eligible for an upgrade to ${os_upgrade_name}."
exit 0
