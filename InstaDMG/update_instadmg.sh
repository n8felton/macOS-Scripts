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
# Description:	Automates the update process for InstaDMG.
# 				1.  Checks if EUID is 0 (root)
#				2.  Checks the current local revision against the remote revision.
#					Updates the SVN if the local revision is out of date.
#				3.	Updates the images defined.
#				4.	Moves the updated images to the DeploySudio Masters folder.
#				5.	Emails the log file to the provided email address.
#
[[ $EUID -ne 0 ]] && echo "Requires elevation. Please run as root or use \"sudo\" ($EUID)" && exit 1

SCRIPT_START=$(date +%s)

SCRIPT_PATH=$(dirname $0)
SCRIPT_NAME=$(basename $0 .sh)

LOG="/var/log/$SCRIPT_NAME.log"
EMAIL=""

LOCAL_REV=$(svnversion | sed -e 's/.*://' -e 's/[A-Z]*$//')
REMOTE_REV=$(svn info | egrep '^Revision: .*$' | sed 's|^Revision: \(.*\)$|\1|')

#Sometimes the $REMOVE_REV is not set. This prevents running blind.
[ -z $REMOTE_REV ] && exit 2

# If the local version is already at the latest revision, exit the script.
[ $REMOTE_REV -eq $LOCAL_REV ] && echo "$SCRIPT_NAME: Revisions match... exiting." && exit 3

# Moves the old log to a log with the old revison number.
[ -f $LOG ] && mv $LOG "${LOG}-${LOCAL_REV}.log"

exec > >(tee "${LOG}" ) 2>&1

echo $(date)

echo "Remote Revision: $REMOTE_REV"
echo "Local Revision: $LOCAL_REV"

svn status
svn update

$SCRIPT_PATH/AddOns/InstaUp2Date/instaUp2Date.py 10.6_rit_vanilla --process
$SCRIPT_PATH/AddOns/InstaUp2Date/instaUp2Date.py 10.7_rit_vanilla --process

[ $? = 0 ] && mv -v /instadmg/OutputFiles/10.6.8_InstaDMG.dmg \
	/DeployStudio/Masters/HFS/10.6.8_InstaDMG-$REMOTE_REV.hfs.dmg
	
[ $? = 0 ] && mv -v /instadmg/OutputFiles/10.7_InstaDMG.dmg \
	/DeployStudio/Masters/HFS/10.7_InstaDMG-$REMOTE_REV.hfs.dmg

SCRIPT_END=$(date +%s)
SCRIPT_ELAPSED=$(expr $SCRIPT_END - $SCRIPT_START)

echo "Elapsed Time: $(date -u -r $SCRIPT_ELAPSED +%H:%M:%S)"

uuencode $LOG $SCRIPT_NAME.log | mail -s "$SCRIPT_NAME Completed - Current Revision: $REMOTE_REV" "$EMAIL"

[ $? = 0 ] && echo "Email Sent"
