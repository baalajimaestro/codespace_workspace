#! /bin/bash

sudo supervisord
sudo chgrp docker /var/run/docker.sock
