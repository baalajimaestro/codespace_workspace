#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
sudoIf()
{
    if [ "$(id -u)" -ne 0 ]; then
        sudo "$@"
    else
        "$@"
    fi
}
# explicitly remove dockerd and containerd PID file to ensure that it can start properly if it was stopped uncleanly
# ie: docker kill <ID>
sudoIf find /run /var/run -iname 'docker*.pid' -delete || :
sudoIf find /run /var/run -iname 'container*.pid' -delete || :
set -e
## Dind wrapper script from docker team
# Maintained: https://github.com/moby/moby/blob/master/hack/dind
export container=docker
if [ -d /sys/kernel/security ] && ! sudoIf mountpoint -q /sys/kernel/security; then
	sudoIf mount -t securityfs none /sys/kernel/security || {
		echo >&2 'Could not mount /sys/kernel/security.'
		echo >&2 'AppArmor detection and --privileged mode might break.'
	}
fi
# Mount /tmp (conditionally)
if ! sudoIf mountpoint -q /tmp; then
	sudoIf mount -t tmpfs none /tmp
fi
# cgroup v2: enable nesting
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
	# move the init process (PID 1) from the root group to the /init group,
	# otherwise writing subtree_control fails with EBUSY.
	sudoIf mkdir -p /sys/fs/cgroup/init
	sudoIf echo 1 > /sys/fs/cgroup/init/cgroup.procs
	# enable controllers
	sudoIf sed -e 's/ / +/g' -e 's/^/+/' < /sys/fs/cgroup/cgroup.controllers \
		> /sys/fs/cgroup/cgroup.subtree_control
fi
## Dind wrapper over.
# Handle DNS
set +e
cat /etc/resolv.conf | grep -i 'internal.cloudapp.net'
if [ $? -eq 0 ]
then
  echo "Setting dockerd Azure DNS."
  CUSTOMDNS="--dns 168.63.129.16"
else
  echo "Not setting dockerd DNS manually."
  CUSTOMDNS=""
fi
set -e
# Start docker/moby engine
( sudoIf dockerd $CUSTOMDNS > /tmp/dockerd.log 2>&1 )
