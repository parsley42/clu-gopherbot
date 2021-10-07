#!/bin/bash

# NOTE: this sample job uses the bot library, most jobs probably won't
source $GOPHER_INSTALLDIR/lib/gopherbot_v1.sh

Say "Task: $GOPHER_TASK_NAME, very secret: $VERY_SECRET, key name: $KEYNAME"
Say "Task: $GOPHER_TASK_NAME, not very secret: $NOT_VERY_SECRET"
