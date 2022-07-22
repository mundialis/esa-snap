#!/bin/sh

## From here https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539785/Update+SNAP+from+the+command+line

/usr/local/snap/bin/snap --nosplash --nogui --modules --update-all 2>&1 | while read -r line; do
    echo "$line"
    if [ "$line" = "updates=0" ]
    then
      echo "Ok"
      sleep 2
      echo "Stopping Now"
      pkill -TERM -f java
    fi
done