#!/bin/bash
wget -q $1 -O - | tr '\n' ' ' | grep -oP '<title>(.*)</title>' | perl -pe 's/<.?title>//g'
