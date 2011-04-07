#!/bin/sh
# $Id: botchk.sh 37 2009-11-13 05:20:22Z discore $
# script used in cron to check if bot is running
#
# most of this code is borrowed from botchk.sh in eggdrop 1.1.5

# Change this to the directory your bot runs from
botdir="/absolute/path/to/poebot"

# Change this to the command used to restart your bot
# NOTE: You must use -b (--background) to put the bot in the background, and
#	   don't include the leading ./
botscript="poebot.pl"

# Change this to the case-sensitive nickname of your bot
botname="poebot"


# begin script
cd $botdir

if test -r .$botname.pid; then
	botpid=`cat .$botname.pid`
	if `kill -CONT $botpid >/dev/null 2>&1`; then
		echo "Bot found, exiting"
		exit 0
	fi
	echo "Stale .$botname.pid file, deleting"
	rm -f .$botname.pid
fi
echo "Couldn't find the bot running, restarting"
./$botscript
exit 0

