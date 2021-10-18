#!/bin/bash

echo "************** My HOME is $HOME"
echo "************** My GOPHER_HOME is $GOPHER_HOME"
echo "************** My working directory is $(pwd)"

set -x
GOPHERBOT=/opt/gopherbot/gopherbot
if [ -x $HOME/gopherbot ]
then
    GOPHERBOT="$HOME/gopherbot"
fi

$GOPHERBOT decrypt -f $HOME/custom/terraform.enc > terraform.sh
