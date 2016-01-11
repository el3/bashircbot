#!/bin/bash

. .bot.config
input=".bot.output"
echo "NICK $nick" > $input 
echo "USER $user" >> $input
joined="false"

tail -f $input | netcat $server 6667 | while read res
do

  case "$res" in
    # respond to ping requests from the server
    PING*)
      echo "$res" | sed "s/I/O/" >> $input
      echo "$res"
    ;;

   *"001 $nick"*) # The first message sent after client registration. The text used varies widely https://www.alien.net.au/irc/irc2numerics.html
      echo "$res"
      if [ "$joined" = "false" ]
        then
          for i in "${channels[@]}"
            do
            echo "JOIN #$i" >> $input
          done
          echo "PRIVMSG NickServ :identify $passwd" >> $input
          joined="true"
      fi
    ;;
    
    # run when a message is seen
    *PRIVMSG*)

      echo "$res"
      
      # If you need to know who sent the command for some reason
      from=$(echo "$res" | perl -pe "s/.*PRIVMSG (.*[#]?([a-zA-Z]|\-)*) :.*/\1/")
      
      # the command itself
      cmd=$(echo "$res" | perl -pe "s/^.*?PRIVMSG\s#.*?:#\s(.*?)\r/\1/")
      
      # Extract the prefix from  the msg. Example if you send "# ls -lah" # is the prefix
      prefix=$(echo "$res" | perl -pe "s/^.*?PRIVMSG\s#.*?:(.)\s.*/\1/")
      
      # Delete the script reference from the output when command fails.
      # Needs to be the line number where the command is evaluated -> eval $cmd > .output is
      cmd="$cmd 2>&1 | sed 's/.\/.bot.sh: line 53: //'"
      i="0"  # a counter if you want to max the number of outputted lines from one command
      
      if [ "$prefix" = "$cmdprefix" ] # if the prefix matches
      then
        eval $cmd > .output  # this is the line where the command is evaluated. And the output is written to .output
        while read p; do     # for each line in .output
            if [ $i -lt $maxlines ] # If you have set the maxlines to 10 in .bot.config. 
              then
              echo "PRIVMSG $from :"$p >> $input  # then it will print the 10 first lines of .output
              sleep 0.8                           # sleep time, or else it will disconnect when to many lines
            fi
            i=$[$i+1] # increment counter
        done <.output        # .output is passed to the while loop
      fi

    ;;

    *)
      echo "$res"
    ;;
  esac
done
