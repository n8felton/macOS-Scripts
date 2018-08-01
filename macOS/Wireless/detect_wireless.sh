#!/bin/bash
# Check if there is a wireless service called "AirPort" available
# 10.4 - 10.6
airport=$(/usr/sbin/networksetup -listallnetworkservices \
  | /usr/bin/grep AirPort)
if [[ -n "${airport}" ]]; then
  airport_exists=1
fi

# Check if there is a wireless service called "Wi-Fi" available
# 10.7+
wifi=$(/usr/sbin/networksetup -listallnetworkservices \
  | /usr/bin/grep Wi-Fi)
if [[ -n "${wifi}" ]]; then
  wifi_exists=1
fi
