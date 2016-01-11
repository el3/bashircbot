#!/bin/bash

cmd="$1 2>&1 | sed 's/.\/.cmd.sh: line 4: //'"  # remove the script reference from error
eval "$cmd" > .output
