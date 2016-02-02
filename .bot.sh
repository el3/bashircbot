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
      
      # the channel the command was sent from
      channel=$(echo "$res" | perl -pe "s/.*PRIVMSG (.*[#]?([a-zA-Z]|\-)*) :.*/\1/")
      
      # the command itself
      cmd=$(echo "$res" | awk 'BEGIN { FS = "^.*?PRIVMSG.*?:[#$]|[\r\n]" } {print $2}') # [$#]
      
      # Who sent the command
      from=$(echo "$res" | perl -pe "s/^:(.*?)!.*/\1/")
      
      i="0"  # a counter if you want to max the number of outputted lines from one command
      
      if [ "$cmd" != ""  ]
          then
          cmd="$cmd 2>&1 | sed 's/.bot.sh: line 51: //'"  # remove the script reference from error
          eval "$cmd" > .output
          while read p; do     # for each line in .output
              if [ $i -lt $maxlines ]  # If you have set the maxlines to 10 in .bot.config. 
                then
                echo "PRIVMSG $channel :$p" >> $input  # then it will print the 10 first lines of .output
                sleep 0.1                         # sleep time, or else it will disconnect when to many lines
              fi
              i=$[$i+1] # increment counter
          done <.output        # .output is passed to the while loop
          rm .output
      fi
    ;;

    *)
      echo "$res"
    ;;
  esac
done
