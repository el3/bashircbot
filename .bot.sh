#!/bin/bash

. .bot.properties
input=".bot.cfg"
echo "NICK $nick" > $input 
echo "USER $user" >> $input
joined="false"

tail -f $input | netcat $server 6667 | while read res
do

  case "$res" in
    # respond to ping requests from the server
    PING*)
      echo "$res" | sed "s/I/O/" >> $input 
    ;;

   *"001 $nick"*)
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
      from=$(echo "$res" | perl -pe "s/.*PRIVMSG (.*[#]?([a-zA-Z]|\-)*) :.*/\1/")
      cmd=$(echo "$res" | perl -pe "s/^.*?PRIVMSG\s#.*?:#\s(.*?)\r/\1/")
      prefix=$(echo "$res" | perl -pe "s/^.*?PRIVMSG\s#.*?:(#)\s.*/\1/")
      cmd="$cmd 2>&1 | sed 's/.\/.bot.sh: line 43: //'"
      i="0"
      
      if [ "$prefix" = '#' ]
      then
        echo 1 >> .output.txt
        eval $cmd > .output.txt
        while read p; do
            if [ $i -lt 10 ]
              then
              echo "PRIVMSG $from :"$p >> $input
              sleep 0.8
            fi
            i=$[$i+1]
        done <.output.txt
      fi

    ;;

    *)
      echo "$res"
    ;;
  esac
done
