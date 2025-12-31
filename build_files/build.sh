#!/bin/bash

set -ouex pipefail

echo ">>> Setting up the repository... <<<"

# 1. Setup Repository
wget https://pkg.surfacelinux.com/fedora/linux-surface.repo -O /etc/yum.repos.d/linux-surface.repo
sed -i 's|$releasever|43|g' /etc/yum.repos.d/linux-surface.repo

echo ">>> Bypassing dracut / rpmostree <<<"

pushd /usr/lib/kernel/install.d
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x  05-rpmostree.install 50-dracut.install
popd

echo ">>> Swaping Surface Kernel <<<"

dnf5 -y swap kernel kernel-surface
#dnf5 -y swap kernel-core kernel-surface-core
#dnf5 -y swap kernel-modules kernel-surface-modules
#dnf5 -y swap kernel-modules-core kernel-surface-modules-core
dnf5 -y swap kernel-modules-extra kernel-surface-modules-extra
dnf5 -y swap kernel-modules-akmods kernel-surface-modules-akmods
dnf5 -y swap kernel-devel kernel-surface-devel
dnf5 -y swap kernel-devel-matched kernel-surface-devel-matched
dnf5 -y swap kernel-tools kernel-surface-tools
dnf5 -y swap kernel-tools-libs kernel-surface-tools-libs
dnf5 -y swap kernel-common kernel-surface-common
dnf5 -y swap libwacom libwacom-surface
dnf5 -y swap libwacom-data libwacom-surface-data

dnf5 versionlock add \
    kernel-surface \
    kernel-surface-core \
    kernel-surface-modules \
    kernel-surface-modules-core \
    kernel-surface-modules-extra \
    kernel-surface-modules-akmods \
    kernel-surface-devel \
    kernel-surface-devel-matched \
    kernel-surface-tools \
    kernel-surface-tools-libs \
    kernel-surface-common \
    libwacom-surface \
    libwacom-surface-data

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

echo ">>> Installing Kernel related packages <<<"

dnf5 -y install \
    surface-control \
    surface-dtx-daemon \
    surface-secureboot

    # iptsd

echo ">>> Installing additional packages... <<<"

# Installing other packages

dnf5 -y install libreoffice

# 3. Cleanup and Configuration
echo ">>> Configuring System Files... <<<"

mkdir -p /etc/bazaar/
echo "    - org.libreoffice.LibreOffice" >> /etc/bazaar/blocklist.yaml

rm -f /usr/share/applications/Discourse.desktop
rm -f /usr/bin/boot-to-windows
rm -f /usr/share/applications/boot-to-windows.desktop

# 4. Finalizing
# Cleanup dnf metadata to keep image size down
dnf5 clean all
