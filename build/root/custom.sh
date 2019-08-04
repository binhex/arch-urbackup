#!/bin/bash

# exit script if return code != 0
set -e

package="urbackup2-server"

# install pre-req packages for this package
pacman -S crypto++ fuse --noconfirm

cd /tmp

# download and extract tarball (do not make or install)
apacman -G "${package}" --noconfirm
cd "./${package}"

# strip out restriction to not allow make as user root
sed -i -e 's~exit $E_ROOT~~g' '/usr/bin/makepkg'

# strip out extended cpu features to allow support for older procs
sed -r -i -e 's~-march=native\s?~~g' 'PKGBUILD'

# compile package
/usr/bin/makepkg

# install compiled package using pacman
pacman -U ${package}*.tar.xz --noconfirm
