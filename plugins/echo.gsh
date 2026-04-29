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
Commands:
- Command: "repeat"
  Regex: '(?i:repeat( me)?)'
  Keywords: [ "repeat" ]
  Usage: "(alias) repeat me"
  Summary: "prompt for a phrase and repeat it back"
  Examples:
  - "(alias) repeat me"
  Helptext: [ "(alias) repeat (me) - prompt for and trivially repeat a phrase" ]
- Command: "echo"
  Regex: '(?i:echo ([^\n]*))'
  Keywords: [ "echo" ]
  Usage: "(alias) echo <something>"
  Summary: "tell the bot to say <something>"
  Examples:
  - "(alias) echo hello world"
  Helptext: [ "(alias) echo <something> - tell the bot to say <something>" ]
- Command: "echo"
  Regex: '(?i:necho (.*))'
  Keywords: [ "echo", "multiline" ]
  Usage: "(alias) necho <message>"
  Summary: "echo full multi-line input without collapse"
  Examples:
  - "(alias) necho hello"
  Helptext: [ "(alias) necho <message> - echo full multi-line input without collapse" ]
- Command: "protocol-say"
  Regex: '(?i:protocol[- ]say\s+([^\s]+)\s+([^\s]+)\s+([^\n]+))'
  Keywords: [ "protocol-say", "protocol", "say" ]
  Usage: "(alias) protocol-say <proto> <channel> <message>"
  Summary: "send a cross-protocol channel message"
  Examples:
  - "(alias) protocol-say slack clu-jobs hello"
  Helptext: [ "(alias) protocol-say <proto> <channel> <message> - send a cross-protocol channel message" ]
- Command: "protocol-tell"
  Regex: '(?i:protocol[- ]tell\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\n]+))'
  Keywords: [ "protocol-tell", "protocol", "tell" ]
  Usage: "(alias) protocol-tell <proto> <channel> <user> <message>"
  Summary: "send a cross-protocol directed message"
  Examples:
  - "(alias) protocol-tell slack general parsley hi"
  Helptext: [ "(alias) protocol-tell <proto> <channel> <user> <message> - send a cross-protocol directed message" ]
- Command: "twiddle"
  Regex: '(?i:twiddle thumbs ([0-9]+[smhd]?))'
  Keywords: [ "twiddle", "thumbs" ]
  Usage: "(alias) twiddle thumbs <timespec>"
  Summary: "loop indefinitely while twiddling thumbs"
  Examples:
  - "(alias) twiddle thumbs 2s"
  Helptext: [ "(alias) twiddle thumbs <timespec> - Log a debug message and sleep for timespec, in a loop" ]
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
		AddTask "say" "I said it from gsh, alright!"
		AddTask "status" "I gave status with gsh, alright!"
		# FinalTask "email-log"
		# /bin/false
		;;
	"protocol-say")
		PROTO="$1"
		CHANNEL="$2"
		shift 2
		MSG="$*"
		if [ -z "$PROTO" ] || [ -z "$CHANNEL" ] || [ -z "$MSG" ]
		then
			Reply "Usage: protocol-say <proto> <channel> <message>"
			exit 0
		fi
		SendProtocolUserChannelMessage "$PROTO" "" "$CHANNEL" "$MSG"
		RETVAL=$?
		if [ $RETVAL -ne $GBRET_Ok ]
		then
			Reply "protocol-say failed ($RETVAL)"
		else
			Reply "protocol-say sent to $PROTO/$CHANNEL"
		fi
		;;
	"protocol-tell")
		PROTO="$1"
		CHANNEL="$2"
		TARGET_USER="$3"
		shift 3
		MSG="$*"
		if [ -z "$PROTO" ] || [ -z "$CHANNEL" ] || [ -z "$TARGET_USER" ] || [ -z "$MSG" ]
		then
			Reply "Usage: protocol-tell <proto> <channel> <user> <message>"
			exit 0
		fi
		SendProtocolUserChannelMessage "$PROTO" "$TARGET_USER" "$CHANNEL" "$MSG"
		RETVAL=$?
		if [ $RETVAL -ne $GBRET_Ok ]
		then
			Reply "protocol-tell failed ($RETVAL)"
		else
			Reply "protocol-tell sent to $PROTO/$CHANNEL (user: $TARGET_USER)"
		fi
		;;
	"twiddle")
		TIMESPEC="$1"
		Say "ok, I'm twiddling my thumbs..."
		while true; do
			Log "Debug" "twiddling thumbs for $TIMESPEC"
			sleep "$TIMESPEC"
		done
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
