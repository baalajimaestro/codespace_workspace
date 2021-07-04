#! /bin/bash

sudo /usr/bin/supervisord -c /etc/supervisord.conf
sudo chgrp docker /var/run/docker.sock
