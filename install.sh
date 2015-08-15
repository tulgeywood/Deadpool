#!/bin/sh
#cleanup old versions if they are already installed
launchctl unload /Library/LaunchDaemons/com.jamfsoftware.fourthWall.plist
rm -rf /Library/Application\ Support/JAMF/ManagementFrameworkScripts/wade.sh
rm -rf /Library/Application\ Support/JAMF/ManagementFrameworkScripts/fourthWall.sh
rm -rf /Library/LaunchDaemons/com.jamfsoftware.fourthWall.plist
#download and make executable wade.sh
curl -s https://raw.githubusercontent.com/tulgeywood/Deadpool/master/wade.sh \
-o /Library/Application\ Support/JAMF/ManagementFrameworkScripts/wade.sh
chmod +x /Library/Application\ Support/JAMF/ManagementFrameworkScripts/wade.sh
#download and make executable fourthwall.sh
curl -s https://raw.githubusercontent.com/tulgeywood/Deadpool/master/fourthWall.sh \
-o /Library/Application\ Support/JAMF/ManagementFrameworkScripts/fourthWall.sh
chmod +x /Library/Application\ Support/JAMF/ManagementFrameworkScripts/fourthWall.sh
#download and load up the fourthWall LaunchDaemon
curl -s https://raw.githubusercontent.com/tulgeywood/Deadpool/master/com.jamfsoftware.fourthWall.plist \
-o /Library/LaunchDaemons/com.jamfsoftware.fourthWall.plist
launchctl load /Library/LaunchDaemons/com.jamfsoftware.fourthWall.plist
#restart all jamf processes and let fourthWall introduce Wade to the Every 15 LaunchDaemon
pkill -f '/usr/sbin/jamf'
jamf manage | xargs -I{} printf '%s %s\n' "$(date '+%b %d %H:%M:%S')" "{}" >> /var/log/jamfv.log
