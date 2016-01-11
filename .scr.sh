#!/bin/bash

session=$(screen -list | awk '{print $1}' | grep "^[0-9]*.$1$")

if [ "$session" = "" ] ; then
    screen -d -m -S $1
    session=$(screen -list | awk '{print $1}' | grep "^[0-9]*.$1$")
    screen -S $session -X $(./.cmd.sh "$2") > /dev/null
else
    screen -S $session -X $(./.cmd.sh "$2") > /dev/null
fi
