#!/bin/bash

# create folder structure for config, temp and logs
mkdir -p /config/urbackup/sqlite/tmp
mkdir -p /config/urbackup/log
mkdir -p /config/urbackup/tmp
mkdir -p /config/urbackup/config

# if config file doesnt exist then copy default
if [[ ! -f /config/urbackup/config/urbackupsrv ]]; then
	cp /etc/default/urbackupsrv /config/urbackup/config/urbackupsrv
fi

# run urbackup server
/usr/bin/urbackupsrv run --config /config/urbackup/config/urbackupsrv --no-consoletime
