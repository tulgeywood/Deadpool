# Overview

It is very easy to create a policy or script that will accidentally hang your JAMF binary on client machines. Mess up a simple loop and the computer will check-in or update EAs forever. Sadly, JAMF doesn't offer a particuraly robust log for troubleshooting these issues either making troubleshooting a daunting task at times.

Enter Deadpool. Using two lightweight scripts and one additional LaunchDaemon, Deadpool makes sure your check-ins don't hang around longer than they should outputs verbose logs about everything that is going on. All of this is integrated into the normal check-in process so self healing occurs quickly and seamlessly.

# Standard JAMF check-in process
A machine enrolled in JAMF has a LaunchDaemon call com.jamfsoftware.task.1.plist. This LaunchDaemon serves one purpose, every 15 minutes (or whatever you set in your JSS) it will run the command `jamf policy -randomDelaySeconds 300`. That's it.

# Deadpool check-in process
A machine using Deadpool will have the same LaunchDaemon, but instead of invoking a check-in from the LaunchDaemon itself it call `wade.sh`. Wade will set a 10 minute timer for the checkin and run `jamf policy -randomDelaySeconds 300 --verbose >> /var/log/jamfv.log` (with some magic in the middle to add timestamps.) If 10 minutes runs out before the check-in process completes Wade will kill all the JAMF processes and let them respawn. If Wade does this 3 times in a row the `jamf manage` command will be invoked via a new LaunchDaemon called com.jamfsoftware.fourthWall.plist. 

fouthWall's sole purpose is to activate when com.jamfsoftware.jamf.daemon.plist is touched. As this is one of the items `jamf manage` replaces, fourthWall always knows when to jump in and fix things so that Wade stays in the picture.

Optionally, if you want to keep thing extra mouthy, the standard inventory update policy can be replaced by a one line script that runs `jamf recon --verbose | xargs -I{} printf '%s %s\n' "$(date '+%b %d %H:%M:%S')" "{}" >> /var/log/jamfv.log`. This ensures all logs are in one place and as verbose as possible.

#Installation
When you're ready to install just setup a script in your JSS to run `curl -sL bit.ly/1KndHNE | bash & disown`. You can also run it manually as root or package the files for distribution if you like. Doing this pipes the install.sh script directly to bash.

#Overriding the timeout for specific policies
There are some circumstances in which you may need to override the 10 minute timeout for a policy. You can do this by creating a new script called `10 Minute Override` in your JSS. Just add the one liner `jamf policy -trigger $4 --verbose & disown`. You can then use the `$4` parameter in a policy to point to the custom trigger of any other policy for which you'd like to ignore the 10 minute timeout. You may notice the output of this policy is not set to be verbose nor to point to the `/var/log/jamfv.log` file. This is because it will be asynchronous to the remaining log output from the check-in and would look awfully messy.
