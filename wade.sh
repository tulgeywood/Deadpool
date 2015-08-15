#!/bin/sh
#logging function
logOutput(){
  $1 | xargs -I{} printf '%s %s\n' "$(date '+%b %d %H:%M:%S')" "{}" >> /var/log/jamfv.log
}
#set time based variables
startTime=$(date +%s)
timeout=600
#check previous consecutive kills value
if tail -n 1 /var/log/jamfv.log | grep -q 'Consecutive kills: '; then
  kills=$(awk 'END {print $NF}' /var/log/jamfv.log)
else
  kills=0
fi
#start checkin
logOutput "echo Starting check-in..."
logOutput '/usr/sbin/jamf policy -randomDelaySeconds 300 --verbose' &
#get checkin PID and increase timeout by randomDelaySeconds value
sleep 1
PID=$(pgrep -f 'jamf policy -randomDelaySeconds')
timeout=$(($(awk 'END {print $5}' /var/log/jamfv.log) + $timeout))
#wait until timeout before killing jamf processes
while kill -0 $PID >/dev/null 2>&1; do
  if [[ $(($(date +%s) - $startTime)) -gt $timeout ]]; then
    logOutput "echo Restarting all jamf processes..."
    pkill -f '/usr/sbin/jamf'
    kills=$((kills+1))
    sleep 2
    #if the checkin has been killed 3 times already run jamf manage by touching the jamf.daemon.plist
    if [ $kills -gt 2 ]; then
      logOutput "echo Killed 3 times in a row. Triggering remanagement..."
      touch /Library/LaunchDaemons/com.jamfsoftware.jamf.daemon.plist
      exit 1
    fi
    #if checkin has been killed fewer than 4 times update jamfv.log and increment kills value
    logOutput "echo Killed for taking too long. If this issue persists the machine will be remanaged."
    logOutput "echo Check-in failed. Consecutive kills: $kills"
    exit 1
  else
    sleep 1
  fi
done
#output consecutive kills number to jamfv.log`
kills=0
logOutput "echo Check-in successful. Consecutive kills: $kills"
exit 0
