# Overview

It is very easy to create a policy or script that will accidentally hang your JAMF binary on client machines. Mess up a simple loop and the computer will check-in or update EAs forever. Sadly, JAMF doesn't offer a particuraly robust log for troubleshooting these issues either making troubleshooting a daunting task at times.

Enter Deadpool. Using a single LaunchDaemon, Deadpool makes sure your check-ins don't hang around longer than they should and outputs verbose logs about everything that is going on. All of this is integrated into the normal check-in process so self healing occurs quickly and seamlessly.

# Standard JAMF check-in process
A machine enrolled in JAMF has a LaunchDaemon call com.jamfsoftware.task.1.plist. This LaunchDaemon serves one purpose, every 15 minutes (or whatever you set in your JSS) it will run the command `jamf policy -randomDelaySeconds 300`. That's it.

# Deadpool check-in process
A machine using Deadpool will have the same LaunchDaemon, but instead of invoking a check-in from the LaunchDaemon itself it calls a specially internalized script. Deadpool will set a 10 minute timer for the checkin and run `jamf policy -randomDelaySeconds 300 --verbose >> /var/log/jamfv.log` (with some magic in the middle to add timestamps.) If 10 minutes runs out before the check-in process completes Deadpool will kill all the JAMF processes and let them respawn. If Deadpool does this 3 times in a row the `jamf manage` command will be invoked via the com.tulgeywood.deadpool LaunchDaemon. 

com.tulgeywood.deadpool's sole purpose is to activate when com.jamfsoftware.jamf.daemon.plist is touched. As this is one of the items `jamf manage` replaces, com.tulgeywood.deadpool always knows when to jump in and fix things so that Deadpool stays in the picture.

Optionally, if you want to keep things extra mouthy, the standard inventory update policy can be replaced by a one line script that runs `jamf recon --verbose | while read line; do echo $(date '+%b %d %H:%M:%S') "$line" ; done >> /var/log/jamfv.log`. This ensures all logs are in one place and as verbose as possible.

#Problems Deadpool handles
• JAMF Binary hanging on check-in.

• JAMF Agent hanging on check-in.

• FileVault recovery key redirection hanging on check-in.

• Scripting errors that create infinite loops or unchecked wait times.

• General bad policies that don't play nice

What Deadpool can't fix will likely be in the `/var/log/jamfv.log` file for you to investigate when edge cases arise. Please share those scenarios with me so I can make the tool better.

#Things I will be adding
Currently Deadpool will not renroll your machine via a quickadd package. I'm working on a few ideas for doing this in a way that I'm happy with. Stay tuned.

#LaunchDaemon script internalization
LaunchDaemons are limited in what shell commands can be baked in. Pretty much anything outside of a one liner ends up going into a script file and the daemon is pointed to it. The problem with this is your script file needs to be maintained along with the daemon and you need to be sure users won't delete, move, or edit it. Anything happens to the script and your daemon will quietly fail forever. With the first iteration of Deadpool, a deleted script could cause check-ins to stop, which I found unacceptable. I spent time mulling this over and finally found a way to put everything inside the daemon itself.

The daemon now has the scripts in comments at the end of the plist. Instead of telling the daemon to run a script file I have it run a one liner that uses `awk` to pull the desired script out of the comment section and then send that along to `sh`. The result is one file with everything in it. If that file gets deleted the computer keeps checking in and all is good with the world.

#Installation
When you're ready to install just setup a script in your JSS to run the install.sh script. This will create a LaunchDaemon that puts everything into place and then deletes itself. It works this way so that the installer will not interrupt any other policies you have running (though if your check-in takes longer than 10 minutes it will just force its way through.) You can also run it manually as root or package the daemon for distribution if you like.

#Overriding the timeout for specific policies
There are some circumstances in which you may need to override the 10 minute timeout for a policy. You can do this by creating a new script called `10 Minute Override` in your JSS. Just add the one liner `jamf policy -trigger $4 --verbose & disown`. You can then use the `$4` parameter in a policy to point to the custom trigger of any other policy for which you'd like to ignore the 10 minute timeout. You may notice the output of this policy is not set to be verbose nor to point to the `/var/log/jamfv.log` file. This is because it will be asynchronous to the remaining log output from the check-in and would look awfully messy.
