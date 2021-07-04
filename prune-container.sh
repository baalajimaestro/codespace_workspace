#! /bin/bash

if [ ! -f "/workspaces/.dockerprune" ]
then
    sleep 45
    echo "Performing initial prune, please wait!"
    docker system prune -a -f
    touch /workspaces/.dockerprune
else
    echo "Reconnecting to container, so avoiding prune!"
fi
