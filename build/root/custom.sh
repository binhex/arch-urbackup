#!/bin/bash

# exit script if return code != 0
set -e

# name of aur package
aur_package="urbackup2-server"

# location of downloaded and extracted tarball from aur (using aur.sh script)
cd "/tmp/${package}"

# strip out restriction to not allow make as user root
sed -i -e 's~exit $E_ROOT~~g' '/usr/bin/makepkg'

# strip out extended cpu features to allow support for older procs
sed -r -i -e 's~-march=native\s?~~g' 'PKGBUILD'

# compile package
/usr/bin/makepkg

# install compiled package using pacman
pacman -U ${aur_package}*.tar.xz --noconfirm
