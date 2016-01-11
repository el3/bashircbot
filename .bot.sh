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
      
      ./.rec.sh "$res"  # pass the msg to .rec.sh

    ;;

    *)
      echo "$res"
    ;;
  esac
done
