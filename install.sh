#!/bin/sh
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.tulgeywood.deadpool.installer</string>
    <key>ProgramArguments</key>
        <array>
            <string>/bin/sh</string>
            <string>-c</string>
            <string>awk '"'"'/^.... INSTALL$/ {flag=1;next} /^INSTALL ...$/ {flag=0} flag'"'"' /Library/LaunchDaemons/com.tulgeywood.deadpool.installer.plist | sh</string>
        </array>
        <key>RunAtLoad</key>
            <true/>
        <key>AbandonProcessGroup</key>
            <true/>
</dict>
</plist>
<!-- INSTALL
#set some variables
startTime=$(date +%s)
timeout=600
PATH=$PATH'"'"':/usr/local/bin'"'"'
jamfLocation=$(/usr/bin/which jamf)
while $(pgrep -qf '"'"'jamf policy'"'"'); do
  if [[ $(($(date +%s) - $startTime)) -gt $timeout ]]; then
    pkill -f '"'"'$jamfLocation'"'"'
    for pid in $(pgrep -f '"'"'jamfAgent'"'"'); do
        launchctl bsexec $pid launchctl unload /Library/LaunchAgents/com.jamfsoftware.jamf.agent.plist
    done
    launchctl unload /Library/LaunchDaemons/com.jamfsoftware.jamf.daemon.plist
  fi
  echo Waiting...
  sleep 3
done
#cleanup old versions if they are already installed
launchctl unload /Library/LaunchDaemons/com.jamfsoftware.fourthWall.plist
rm -rf /Library/Application\ Support/JAMF/ManagementFrameworkScripts/wade.sh
rm -rf /Library/Application\ Support/JAMF/ManagementFrameworkScripts/fourthWall.sh
rm -rf /Library/LaunchDaemons/com.jamfsoftware.fourthWall.plist
#download and load up the deadpool LaunchDaemon
curl -s https://raw.githubusercontent.com/tulgeywood/Deadpool/master/com.tulgeywood.deadpool.plist \
-o /Library/LaunchDaemons/com.tulgeywood.deadpool.plist
launchctl load /Library/LaunchDaemons/com.tulgeywood.deadpool.plist
#Let deadpool introduce himself to the Every 15 LaunchDaemon
jamf manage | while read line; do echo $(date '"'"'+%b %d %H:%M:%S'"'"') "$line" ; done >> /var/log/jamfv.log
/bin/sh -c "sleep 3 && launchctl remove com.tulgeywood.deadpool.installer" & disown
rm -f /Library/LaunchDaemons/com.tulgeywood.deadpool.installer.plist
INSTALL -->' > /Library/LaunchDaemons/com.tulgeywood.deadpool.installer.plist

launchctl load /Library/LaunchDaemons/com.tulgeywood.deadpool.installer.plist
