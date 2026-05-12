#!/bin/bash

# NOTE: this sample job uses the bot library, most jobs probably won't
source $GOPHER_INSTALLDIR/lib/gopherbot_v1.sh

VERY_SECRET=$(GetParameter "VERY_SECRET")
KEYNAME=$(GetParameter "KEYNAME")
NOT_VERY_SECRET=$(GetParameter "NOT_VERY_SECRET")

Say "Task: $GOPHER_TASK_NAME, very secret: $VERY_SECRET, key name: $KEYNAME"
Say "Task: $GOPHER_TASK_NAME, not very secret: $NOT_VERY_SECRET"
