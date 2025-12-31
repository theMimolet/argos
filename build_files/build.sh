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

echo ">>> Cleaning up old Kernel <<<"

dnf5 -y remove --no-autoremove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-tools kernel-tools-libs libwacom libwacom-data

echo ">>> Installing Surface Kernel <<<"

surface_pkgs=(
    kernel-surface
    kernel-surface-core
    kernel-surface-modules
    kernel-surface-modules-core
    kernel-surface-modules-extra
    kernel-surface-modules-akmods
    kernel-surface-devel
    kernel-surface-devel-matched
    kernel-surface-tools
    kernel-surface-tools-libs
    kernel-surface-common
    libwacom-surface
    libwacom-surface-data
)

dnf5 -y install $surface_pkgs
dnf5 versionlock add $surface_pkgs

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

echo ">>> Installing Kernel related packages <<<"

dnf5 -y install \
    iptsd \
    surface-control \
    surface-dtx-daemon \
    surface-secureboot

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
