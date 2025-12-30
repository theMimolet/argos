#!/bin/bash

set -ouex pipefail

echo ">>> Setting up the repository... <<<"

# 1. Setup Repository
wget https://pkg.surfacelinux.com/fedora/linux-surface.repo -O /etc/yum.repos.d/linux-surface.repo
sed -i 's|$releasever|42|g' /etc/yum.repos.d/linux-surface.repo

echo ">>> Cleaning up version locks <<<"

# We must remove these first or they will block the swap with version requirements
dnf5 -y remove kernel-devel-matched kernel-uki-virt kmod-xone

echo ">>> Swapping Kernels <<<"

# 2. Kernel Swap
dnf5 -y swap kernel kernel-surface
dnf5 -y swap kernel-core kernel-surface-core
dnf5 -y swap kernel-modules kernel-surface-modules
dnf5 -y swap kernel-modules-extra kernel-surface-modules-extra
dnf5 -y swap kernel-devel kernel-surface-devel
dnf5 -y swap libwacom libwacom-surface
dnf5 -y swap libwacom-data libwacom-surface-data

dnf5 -y install \
    kernel-surface-headers \
    iptsd \
    surface-control \
    surface-secureboot \

echo ">>> Installing additionnal packages... <<<"

# Installing other packages

dnf5 install libreoffice

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
