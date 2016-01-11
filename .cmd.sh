#!/bin/bash

cmd="$1 2>&1 | sed 's/.\/.cmd.sh: line 4: //'"
eval "$cmd" > .output
