#!/bin/bash

# create soft link to folder storing urbackup settings
echo "[info] Creating soft link from /config/urbackup to /var/urbackup..."
mkdir -p /config/urbackup ; rm -rf /var/urbackup ; ln -s /config/urbackup /var/urbackup

# run urbackup server
/usr/bin/urbackupsrv run
