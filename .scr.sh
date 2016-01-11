#!/bin/bash

session=$(screen -list | awk '{print $1}' | grep "^[0-9]*.$1$")

# I was experimenting with commands that would crash the bot like nano, tail -f, more, less, etc..
# Create a screen session for each user
# This might not be neccesary
if [ "$session" = "" ] ; then
    screen -d -m -S $1
    session=$(screen -list | awk '{print $1}' | grep "^[0-9]*.$1$")
    screen -S $session -X $(./.cmd.sh "$2") > /dev/null
else
    screen -S $session -X $(./.cmd.sh "$2") > /dev/null
fi
