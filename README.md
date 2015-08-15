# JAMF check-ins with healing factor and a mouth!

It can be very easy to create a policy or script that will accidentally hang your JAMF binary on client machines. Mess up a simple loop and the computer will check-in or update EAs forever. Sadly, JAMF doesn't offer a particuraly robust log for troubleshooting these issues either. Deadpool solves these issue with two lightweight scripts and one additional LaunchDaemon, all the while telling you everything it is doing.

# Standard JAMF check-in process
A machine enrolled in JAMF has a LaunchDaemon call com.jamfsoftware.task.1.plist. This LaunchDaemon serves one purpose, every 15 minutes (or whatever you set in your JSS) it will run the command `jamf policy -randomDelaySeconds 300`. That's it.

# Deadpool check-in process
A machine using Deadpool will have the same LaunchDaemon, but instead of invoking a check-in from the LaunchDaemon itself it call `wade.sh`. Wade will set a 10 minute timer for the checkin and run `jamf policy -randomDelaySeconds 300 --verbose >> /var/log/jamfv.log` (with some magic in the middle to add timestamps.) If 10 minutes runs out before the check-in process completes Wade will kill all the JAMF processes and let them respawn. If Wade does this 3 times in a row the `jamf manage` command will be invoked via a new LaunchDaemon called com.jamfsoftware.fourthWall.plist. 

fouthWall's sole purpose is to activate when com.jamfsoftware.jamf.daemon.plist is touched. As this is one of the items `jamf manage` replaces, fourthWall always knows when to jump in and fix things so that Wade stays in the picture.

Optionally, if you want to keep thing extra mouthy, the standard inventory update policy can be replaced by a one line script that runs `jamf recon --verbose | xargs -I{} printf '%s %s\n' "$(date '+%b %d %H:%M:%S')" "{}" >> /var/log/jamfv.log`. This ensures all logs are in one place and as verbose as possible.
