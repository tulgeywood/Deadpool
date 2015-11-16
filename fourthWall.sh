#!/bin/sh
#logging function
logOutput(){
	$1 | while read line; do echo $(date '+%b %d %H:%M:%S') "$line" ; done >> /var/log/jamfv.log
}
#figure out if we need to run `jamf manage`
if pgrep -qf "jamf manage"; then
	logOutput "echo jamf manage was run manually"
	until ! pgrep -qf "jamf manage"; do
		sleep 1
	done
else
	logOutput 'jamf manage'
	wait
fi
#bring Wade back into the standard Every 15 Minutes LaunchDaemon
sed -i '' -e 's/\/.*\/jamf/\/bin\/sh/g' \
-e 's/policy/\/Library\/Application Support\/JAMF\/ManagementFrameworkScripts\/wade.sh/g' \
-e '/randomDelaySeconds/d' \
-e '/300/d' /Library/LaunchDaemons/com.jamfsoftware.task.1.plist
#reload the LaunchDaemon
launchctl unload /Library/LaunchDaemons/com.jamfsoftware.task.1.plist
launchctl load /Library/LaunchDaemons/com.jamfsoftware.task.1.plist
logOutput "echo Computer has been remanaged"
