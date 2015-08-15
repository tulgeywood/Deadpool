#!/bin/sh
curl -s https://raw.githubusercontent.com/tulgeywood/Deadpool/master/wade.sh \
-o /Library/Application\ Support/JAMF/ManagementFrameworkScripts/wade.sh
chmod +x /Library/Application\ Support/JAMF/ManagementFrameworkScripts/wade.sh

curl -s https://raw.githubusercontent.com/tulgeywood/Deadpool/master/fourthWall.sh \
-o /Library/Application\ Support/JAMF/ManagementFrameworkScripts/fourthWall.sh
chmod +x /Library/Application\ Support/JAMF/ManagementFrameworkScripts/fourthWall.sh

curl -s https://raw.githubusercontent.com/tulgeywood/Deadpool/master/com.jamfsoftware.fourthWall.plist \
-o /Library/LaunchDaemons/com.jamfsoftware.fourthWall.plist
launchctl load /Library/LaunchDaemons/com.jamfsoftware.fourthWall.plist

pkill -f '/usr/sbin/jamf'
jamf manage
