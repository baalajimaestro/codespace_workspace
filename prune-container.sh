#! /bin/bash

sleep 45
if [ ! -f "/workspaces/.dockerprune" ]
then
    echo "Performing initial prune, please wait!"
    docker system prune -a -f
    touch /workspaces/.dockerprune
else
    echo "Reconnecting to container, so avoiding prune!"
fi
