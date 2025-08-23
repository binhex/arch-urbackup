# Application

[UrBackup](https://www.urbackup.org/)

## Description

UrBackup is an easy to setup Open Source client/server backup system, that
through a combination of image and file backups accomplishes both data safety
and a fast restoration time.
File and image backups are made while the system is running without interrupting
current processes.
UrBackup also continuously watches folders you want backed up in order to
quickly find differences to previous backups. Because of that, incremental file
backups are really fast.
Your files can be restored through the web interface, via the client or the
Windows Explorer while the backups of drive volumes can be restored with a
bootable CD or USB-Stick (bare metal restore).
A web interface makes setting up your own backup server really easy. For a quick
impression please look at the screenshots here.

## Build notes

Latest stable UrBackup release from AUR.

## Usage

```bash
docker run -d \
    --net="host" \
    --name=<container name> \
    -v <path for media files>:/media \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e HEALTHCHECK_COMMAND=<command> \
    -e HEALTHCHECK_ACTION=<action> \
    -e HEALTHCHECK_HOSTNAME=<hostname> \
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    binhex/arch-urbackup
```

Please replace all user variables in the above command defined by <> with the
correct values.

## Access application

`<host ip>:55414`

## Example

```bash
docker run -d \
    --net="host" \
    --name=urbackup \
    -v /media/backups:/media \
    -v /apps/docker/urbackup/config:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e UMASK=000 \
    -e PUID=0 \
    -e PGID=0 \
    binhex/arch-urbackup
```

## Notes

User ID (PUID) and Group ID (PGID) can be found by issuing the following command
for the user you want to run the container as:-

```bash
id <username>
```

Caveats whilst running UrBackup:-

- Image mounting is disabled
- ZFS snapshotting cannot be used

___
If you appreciate my work, then please consider buying me a beer  :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MM5E27UX6AUU4)

[Documentation](https://github.com/binhex/documentation) | [Support forum](https://forums.unraid.net/topic/82198-support-binhex-urbackup/)
