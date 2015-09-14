#!/bin/sh
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>com.jamfsoftware.deadpool.installer</string>
		<key>Program</key>
		<string>/Library/Application Support/JAMF/ManagementFrameworkScripts/installer.sh</string>
		<key>RunAtLoad</key>
		<true/>
    <key>AbandonProcessGroup</key>
    <true/>
	</dict>
</plist>' > /Library/LaunchDaemons/com.jamfsoftware.deadpool.installer.plist

echo '#!/bin/sh
#set some variables
startTime=$(date +%s)
timeout=600
jamfLocation=$(/usr/bin/which jamf)

while $(pgrep -qf '"'"'jamf policy'"'"'); do
  if [[ $(($(date +%s) - $startTime)) -gt $timeout ]]; then
    pkill -f '"'"'/usr/$jamfLocation/jamf'"'"'
  fi
  echo Waiting...
  sleep 3
done
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
#Let fourthWall introduce Wade to the Every 15 LaunchDaemon
jamf manage | while read line; do echo $(date '"'"'+%b %d %H:%M:%S'"'"') "$line" ; done >> /var/log/jamfv.log
/bin/sh -c "sleep 3 && launchctl remove com.jamfsoftware.deadpool.installer" & disown
rm -f /Library/LaunchDaemons/com.jamfsoftware.deadpool.installer.plist
rm -f /Library/Application\ Support/JAMF/ManagementFrameworkScripts/installer.sh' > /Library/Application\ Support/JAMF/ManagementFrameworkScripts/installer.sh

chmod +x /Library/Application\ Support/JAMF/ManagementFrameworkScripts/installer.sh
launchctl load /Library/LaunchDaemons/com.jamfsoftware.deadpool.installer.plist
