#!/bin/bash

input=".bot.output"
res="$1"
. .bot.config

# the channel the command was sent from
channel=$(echo "$res" | perl -pe "s/.*PRIVMSG (.*[#]?([a-zA-Z]|\-)*) :.*/\1/")

# the command itself
cmd=$(echo "$res" | perl -pe "s/^.*?PRIVMSG\s#.*?:#\s(.*?)\r/\1/")

# Extract the prefix from  the msg. Example if you send "# ls -lah" # is the prefix
prefix=$(echo "$res" | perl -pe "s/^.*?PRIVMSG\s#.*?:(.)\s.*/\1/")

# Who sent the command
from=$(echo "$res" | perl -pe "s/^(.*?)!.*/\1/")

i="0"  # a counter if you want to max the number of outputted lines from one command

if [ "$prefix" = "$cmdprefix" ] # if the prefix matches
    then
    ./.scr.sh $from "$cmd" &
    sleep 0.5
    while read p; do     # for each line in .output
        if [ $i -lt $maxlines ] # If you have set the maxlines to 10 in .bot.config. 
          then
          echo "PRIVMSG $channel :$p" >> $input  # then it will print the 10 first lines of .output
          sleep 0.8                           # sleep time, or else it will disconnect when to many lines
        fi
        i=$[$i+1] # increment counter
    done <.output        # .output is passed to the while loop
    rm .output
fi
