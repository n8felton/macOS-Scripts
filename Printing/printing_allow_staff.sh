#!/bin/bash
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." 
  exit 1
fi

GROUP="staff"
preferences=(
  "system.preferences" \
  "system.preferences.printing" \
  "system.print.admin")

system_preferences_plist="${TMPDIR}/preference.plist"

defaults write "${system_preferences_plist}" allow-root -bool TRUE
defaults write "${system_preferences_plist}" authenticate-user -bool TRUE
defaults write "${system_preferences_plist}" class -string user
defaults write "${system_preferences_plist}" group "${GROUP}"
defaults write "${system_preferences_plist}" session-owner -bool TRUE
defaults write "${system_preferences_plist}" shared -bool TRUE
  
for preference in "${preferences[@]}"; do
  /usr/bin/security \
  authorizationdb \
  write \
  ${preference} 2>/dev/null < "${system_preferences_plist}"
done
