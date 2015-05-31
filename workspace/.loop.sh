#!/bin/bash
res=$2
. .bot.properties
input="/home/ubuntu/workspace/.bot.cfg"

      echo "$res"
      who=$(echo "$res" | perl -pe "s/:(.*)\!.*@.*/\1/")
      from=$(echo "$res" | perl -pe "s/.*PRIVMSG (.*[#]?([a-zA-Z]|\-)*) :.*/\1/")
      cmd=$(echo "$res" | perl -pe "s/^.*?PRIVMSG\s#.*?:#sh\s(.*?)\r/\1/")
      prefix=$(echo "$res" | perl -pe "s/^.*?PRIVMSG\s#.*?:(#sh)\s.*/\1/")
      link=$(echo "$res" | perl -pe "s/^.*?PRIVMSG\s#.*?:.*?(http.*?)\s.*/\1/")
      com="sh"

      i="0"
      
      #if [ "$link" -gt "" ]
      #then
      #  ./getTitle.sh $link >> $input
      #fi
      
      if [ "$prefix" = '#sh' ]
      then
        echo 1 >> /home/ubuntu/workspace/.output.txt
        eval $cmd > /home/ubuntu/workspace/.output.txt
        while read p; do
            if [ $i -lt 100 ]
              then
              echo "PRIVMSG $from :"$p >> $input
              sleep 0.8
            fi
            i=$[$i+1]
        done </home/ubuntu/workspace/.output.txt
      fi