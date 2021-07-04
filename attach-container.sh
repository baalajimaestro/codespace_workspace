#! /bin/bash

sudo /usr/sbin/sshd
sudo chgrp docker /var/run/docker.sock

if [ ! -f "/workspaces/.dockerprune" ]
then
    echo "Performing initial prune, please wait!"
    sudo docker system prune -a -f
    touch /workspaces/.dockerprune
else
    echo "Reconnecting to container, so avoiding prune!"
fi
