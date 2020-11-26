#!/bin/bash -e

# jobs/sleep.sh - just sleep for a while, for dev

# NOTE: this sample job uses the bot library, most jobs probably won't
source $GOPHER_INSTALLDIR/lib/gopherbot_v1.sh

echo "Nighty-night!"
sleep 20m
echo "*yawn*"
