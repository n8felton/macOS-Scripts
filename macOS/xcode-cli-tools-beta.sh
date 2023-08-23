#!/bin/bash
# Origainally from https://github.com/timsutton/osx-vm-templates/blob/8a2d0be3b8c3d3ba81aa49e7930a2d65ed7e70fc/scripts/xcode-cli-tools.sh
# Thanks to Tim Sutton

# create the placeholder file that's checked by CLI updates .dist code
# in Apple's SUS catalog
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
# https://developer.apple.com/documentation/xcode-release-notes/xcode-15-release-notes
sudo mkdir -p /Library/Developer/CommandLineTools
sudo touch /Library/Developer/CommandLineTools/.beta
# find the CLI Tools update
PROD=$(softwareupdate -l | awk -F"*" '/^ *\*.*Command Line Tools/ {gsub(/^[[:space:]]|Label: /,"",$2); print $2;}' | head -1)
# install it
softwareupdate -i "${PROD}" --verbose
# cleanup the placeholder
rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
