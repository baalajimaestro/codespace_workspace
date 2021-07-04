#! /bin/bash

sudo /usr/bin/supervisord
sudo chgrp docker /var/run/docker.sock
