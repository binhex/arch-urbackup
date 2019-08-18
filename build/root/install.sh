#!/bin/bash

# exit script if return code != 0
set -e

# build scripts
####

# download build scripts from github
curl --connect-timeout 5 --max-time 600 --retry 5 --retry-delay 0 --retry-max-time 60 -o /tmp/scripts-master.zip -L https://github.com/binhex/scripts/archive/master.zip

# unzip build scripts
unzip /tmp/scripts-master.zip -d /tmp

# move shell scripts to /root
mv /tmp/scripts-master/shell/arch/docker/*.sh /usr/local/bin/

# pacman packages
####

# define pacman packages
pacman_packages="crypto++ fuse"

# install compiled packages using pacman
if [[ ! -z "${pacman_packages}" ]]; then
	pacman -S --needed $pacman_packages --noconfirm
fi

# aur packages
####

# define aur packages
aur_operations="-G"
aur_options="--noconfirm"
aur_packages="urbackup2-server"
aur_custom_script="/root/custom.sh"

# call aur install script (arch user repo)
source aur.sh

# config - urbackup
####

# path to default urbackup configuration file
urbackup_config="/etc/default/urbackupsrv"

# configure account
sed -i -e 's~USER=".*"~USER="nobody"~g' "${urbackup_config}"

# configure sqlite temp folder
sed -i -e 's~SQLITE_TMPDIR=".*"~SQLITE_TMPDIR="/config/urbackup/sqlite/tmp"~g' "${urbackup_config}"

# configure logfile location
sed -i -e 's~LOGFILE=".*"~LOGFILE="/config/urbackup/log/urbackup.log"~g' "${urbackup_config}"

# configure daemon temp folder
sed -i -e 's~DAEMON_TMPDIR=".*"~DAEMON_TMPDIR="/config/urbackup/tmp"~g' "${urbackup_config}"

# container perms
####

# define comma separated list of paths
install_paths="/usr/share/urbackup,/home/nobody"

# split comma separated string into list for install paths
IFS=',' read -ra install_paths_list <<< "${install_paths}"

# process install paths in the list
for i in "${install_paths_list[@]}"; do

	# confirm path(s) exist, if not then exit
	if [[ ! -d "${i}" ]]; then
		echo "[crit] Path '${i}' does not exist, exiting build process..." ; exit 1
	fi

done

# convert comma separated string of install paths to space separated, required for chmod/chown processing
install_paths=$(echo "${install_paths}" | tr ',' ' ')

# set permissions for container during build - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
chmod -R 775 ${install_paths}

# create file with contents of here doc, note EOF is NOT quoted to allow us to expand current variable 'install_paths'
# we use escaping to prevent variable expansion for PUID and PGID, as we want these expanded at runtime of init.sh
cat <<EOF > /tmp/permissions_heredoc

# get previous puid/pgid (if first run then will be empty string)
previous_puid=\$(cat "/root/puid" 2>/dev/null || true)
previous_pgid=\$(cat "/root/pgid" 2>/dev/null || true)

# if first run (no puid or pgid files in /tmp) or the PUID or PGID env vars are different 
# from the previous run then re-apply chown with current PUID and PGID values.
if [[ ! -f "/root/puid" || ! -f "/root/pgid" || "\${previous_puid}" != "\${PUID}" || "\${previous_pgid}" != "\${PGID}" ]]; then

	# set permissions inside container - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
	chown -R "\${PUID}":"\${PGID}" ${install_paths}

fi

# write out current PUID and PGID to files in /root (used to compare on next run)
echo "\${PUID}" > /root/puid
echo "\${PGID}" > /root/pgid

EOF

# replace permissions placeholder string with contents of file (here doc)
sed -i '/# PERMISSIONS_PLACEHOLDER/{
    s/# PERMISSIONS_PLACEHOLDER//g
    r /tmp/permissions_heredoc
}' /usr/local/bin/init.sh
rm /tmp/permissions_heredoc

# create file with contents of here doc, note EOF is NOT quoted to allow us to expand variables
# we use escaping to prevent variable expansion, as we want these expanded at runtime of init.sh
cat <<EOF > /tmp/config_heredoc
# if volume does not exist or container folder is not soft linked then 
# create/re-create soft link to folder (used to store urbackup settings)
if [[ ! -d /config/urbackup || ! -L /var/urbackup ]]; then
	echo "[info] Creating soft link from /config/urbackup to /var/urbackup..."
	mkdir -p /config/urbackup ; chown -R nobody:users /config/urbackup ; rm -rf /var/urbackup ; ln -s /config/urbackup /var/urbackup
fi

EOF

# replace permissions placeholder string with contents of file (here doc)
sed -i '/# CONFIG_PLACEHOLDER/{
    s/# CONFIG_PLACEHOLDER//g
    r /tmp/config_heredoc
}' /usr/local/bin/init.sh
rm /tmp/config_heredoc

# env vars
####

# cleanup
cleanup.sh
