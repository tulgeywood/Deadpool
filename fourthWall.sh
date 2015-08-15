#!/bin/sh
#logging function
logOutput(){
  $1 | xargs -I{} printf '%s %s\n' "$(date '+%b %d %H:%M:%S')" "{}" >> /var/log/jamfv.log
}
#prevent script running more than one instance of itself
if pgrep -qf "jamf manage"; then
	logOutput "echo jamf manage was run mannually"
	until ! pgrep -qf "jamf manage"; do
		sleep 1
	done
else
	logOutput 'jamf manage'
  wait
fi
#add healing factor to the standard Every 15 Minutes LaunchDaemon
sed -i '' -e 's/\/usr\/sbin\/jamf/\/bin\/sh/g' \
-e 's/policy/\/Library\/Application Support\/JAMF\/ManagementFrameworkScripts\/wade.sh/g' \
-e '/randomDelaySeconds/d' \
-e '/300/d' /Library/LaunchDaemons/com.jamfsoftware.task.1.plist
#reload the LaunchDaemon
launchctl unload /Library/LaunchDaemons/com.jamfsoftware.task.1.plist
launchctl load /Library/LaunchDaemons/com.jamfsoftware.task.1.plist
logOutput "echo Computer has been remanaged"
