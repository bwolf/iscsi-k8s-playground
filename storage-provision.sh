#!/bin/bash

echo I am provisioning
date > /etc/vagrant_provisioned_at

dpkg -s lvm2 >/dev/null || apt-get install -y --no-install-recommends lvm2
dpkg -s tgt >/dev/null || apt-get install -y --no-install-recommends tgt

# EOF
