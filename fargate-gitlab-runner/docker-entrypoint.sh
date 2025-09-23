#!/bin/bash

echo '10.53.56.153 cloudrepo.tsmc.com' >> /etc/hosts

# Restart SSH service
/etc/init.d/ssh restart

exec gitlab-runner run
