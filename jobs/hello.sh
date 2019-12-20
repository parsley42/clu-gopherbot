#!/bin/bash -e

# jobs/hello.sh - the first Gopherbot scheduled job

# NOTE: this sample job uses the bot library, most jobs probably won't
source $GOPHER_INSTALLDIR/lib/gopherbot_v1.sh

PHRASE=$1

if Exclusive "world" "true"
then
    Say "Hooray! I get to run! $GOPHER_CALLER_ID"
else
    Say "Darn, I have to wait. $GOPHER_CALLER_ID"
    exit 0
fi
ls -Fla ..
head /etc/group >&2
sleep 4

FailTask dmnotify parsley "Your trivial hello world job failed"

#set -x
# PHRASE is the argument passed in
Say "$PHRASE / $NONCE - now I'll restart!"
Log "Info" "I said $PHRASE and $NONCE"

AddTask restart
