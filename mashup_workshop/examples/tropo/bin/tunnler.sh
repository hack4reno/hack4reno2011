#!/bin/bash

##Make Tunnlr reverse http proxy, takes port as parameter or defaults to 9876 
##which is sinatra's default port
    
        TUNNLR_PORT=123456  #<---- port goes here
        TUNNLR_USERNAME='tunnlr____' #<--- Username

        PARAMETER=$1    
        PORT=${PARAMETER:=9876}
        
        #Look for existng pid, if found nuke it
        pid=$(ps aux | grep tunnlr | grep -v "grep" | cut -d " " -f6)
        if [ "$pid" == "" ]; then
            echo "No existing pid found, starting tunnlr"
        else
            echo "Found Existing pid(s) [ $pid ], so long sucka"
            kill -9 $pid > /dev/null
        fi
        echo "http://web1.tunnlr.com:$TUNNLR_PORT" | pbcopy
        echo "URL Copied to clipboard"
        ssh -nNt -g -R :$TUNNLR_PORT:0.0.0.0:$PORT $TUNNLR_USERNAME@ssh1.tunnlr.com &
    
