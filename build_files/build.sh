#!/bin/bash

set -ouex pipefail

echo ">>> Setting up the repository... <<<"

# 1. Setup Repository
wget https://pkg.surfacelinux.com/fedora/linux-surface.repo -O /etc/yum.repos.d/linux-surface.repo
sed -i 's|$releasever|42|g' /etc/yum.repos.d/linux-surface.repo

echo ">>> Swapping Kernels <<<"

# 2. Kernel Swap (Combining into one transaction is cleaner)
dnf5 remove -y \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra \
    kernel-devel \
    kernel-devel-matched \
    kernel-headers \
    kmod-xone \
    kernel-uki-virt \
    libwacom

dnf5 install -y \
    kernel-surface \
    kernel-surface-core \
    kernel-surface-modules \
    kernel-surface-modules-core \
    kernel-surface-modules-extra \
    kernel-surface-devel \
    kernel-surface-headers \
    libwacom-surface \
    iptsd \
    surface-control \
    surface-secureboot

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
