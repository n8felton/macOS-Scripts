#!/usr/bin/bash
set -euo pipefail

# Only allow to run as root
if [[ ${EUID} -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

SERIAL_NUMBER=$(ioreg -d2 -k IOPlatformSerialNumber | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')

hostname "${SERIAL_NUMBER}"
scutil --set HostName "${SERIAL_NUMBER}"
scutil --set ComputerName "${SERIAL_NUMBER}"
scutil --set LocalHostName "${SERIAL_NUMBER}"
