#!/usr/bin/dumb-init /bin/bash

# create folder structure for config, temp and logs
mkdir -p /config/urbackup/sqlite/tmp
mkdir -p /config/urbackup/log
mkdir -p /config/urbackup/tmp
mkdir -p /config/urbackup/config

if [[ ! -f /config/urbackup/config/urbackupsrv ]]; then

	# copy default config to volume map
	cp /etc/default/urbackupsrv /config/urbackup/config/urbackupsrv

	# set default location for backup storage to /media
	echo "/media" > /var/urbackup/backupfolder

fi

# run urbackup server
/usr/bin/urbackupsrv run --config /config/urbackup/config/urbackupsrv --no-consoletime
