#!/bin/bash -e

# echo.sh - trivial shell plugin example for Gopherbot

# START Boilerplate
[ -z "$GOPHER_INSTALLDIR" ] && { echo "GOPHER_INSTALLDIR not set" >&2; exit 1; }
source $GOPHER_INSTALLDIR/lib/gopherbot_v1.sh

command=$1
shift
# END Boilerplate

configure(){
	cat <<"EOF2"
---
Help:
- Keywords: [ "repeat" ]
  Helptext: [ "(bot), repeat (me) - prompt for and trivially repeat a phrase" ]
- Keywords: [ "echo" ]
  Helptext: [ "(bot), echo <something> - tell the bot to say <something>" ]
- Keywords: [ "protocol-say" ]
  Helptext: [ "(bot), protocol-say <proto> <channel> [user] - send a simple cross-protocol test message" ]
CommandMatchers:
- Command: "repeat"
  Regex: '(?i:repeat( me)?)'
## This will match the collapsed version of the message;
## 'hello\nworld' will echo 'hello world'
- Command: "echo"
  Regex: '(?i:echo ([^\n]*))'
## This will match the full message; 'hello\nworld' will echo
## 'hello\nworld'
- Command: "echo"
  Regex: '(?i:necho (.*))'
- Command: "protocol-say"
  Regex: '(?i:protocol[- ]say\s+([^\s]+)\s+([^\s]+)(?:\s+([^\s]+))?)'
EOF2
}

case "$command" in
# NOTE: only "configure" should print anything to stdout
	"configure")
		configure
		;;
	"echo")
		echo "Hello, brave new world: $1"
		echo "Hello, error world: $1" >&2
		Say "You *told* me to _say_ '$1'"
		BOTID=$(GetBotAttribute id)
		Say "I think my ID is $BOTID"
		AddTask "say" "I said it, alright!"
		AddTask "status" "I gave status, alright!"
		# FinalTask "email-log"
		# /bin/false
		;;
	"protocol-say")
		PROTO="$1"
		CHANNEL="$2"
		TARGET_USER="$3"
		if [ -z "$PROTO" ] || [ -z "$CHANNEL" ]
		then
			Reply "Usage: protocol-say <proto> <channel> [user]"
			exit 0
		fi
		MSG="protocol-say test from $GOPHER_USER"
		SendProtocolUserChannelMessage "$PROTO" "$TARGET_USER" "$CHANNEL" "$MSG"
		RETVAL=$?
		if [ $RETVAL -ne $GBRET_Ok ]
		then
			Reply "protocol-say failed ($RETVAL)"
		else
			if [ -n "$TARGET_USER" ]
			then
				Reply "protocol-say sent to $PROTO/$CHANNEL (user: $TARGET_USER)"
			else
				Reply "protocol-say sent to $PROTO/$CHANNEL"
			fi
		fi
		;;
	"init")
		echo "Clu starting up!"
		ls -Fla ..
		whoami
		# FinalTask "email-log" "parsley@linuxjedi.org"
		;;
	"repeat")
		REPEAT=$(PromptForReply SimpleString "What do you want me to repeat?")
		RETVAL=$?
		if [ $RETVAL -ne $GBRET_Ok ]
		then
			Reply "Sorry, I had a problem getting your reply: $RETVAL"
		else
			Reply "$REPEAT"
		fi
		# Yah, this makes no sense for repeat - but Clu is a test/debug bot!
		Say "I'm a PLUGIN, and I think VERY_SECRET is: $VERY_SECRET"
		SetParameter NOT_VERY_SECRET "$NOT_VERY_SECRET"

		AddTask privtest
		AddTask nonprivtest
		;;
esac
