#!/bin/bash

set -ouex pipefail

echo ">>> Installing the Surface Kernel... <<<"

# Add the Linux Surface repository
wget https://pkg.surfacelinux.com/fedora/linux-surface.repo -O /etc/yum.repos.d/linux-surface.repo
sed -i 's|$releasever|42|g' /etc/yum.repos.d/linux-surface.repo

# Enable cliwrap to intercept kernel-install scripts
# This is required for kernel operations in container builds

# Override the kernel with Surface kernel
rpm-ostree override remove \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra \
    kernel-devel \
    kernel-devel-matched \
    kernel-headers \
    --install kernel-surface \
    --install kernel-surface-core \
    --install kernel-surface-modules \
    --install kernel-surface-modules-core \
    --install kernel-surface-modules-extra \
    --install kernel-surface-devel \
    --install kernel-surface-devel-matched \
    --install kernel-surface-headers || \
rpm-ostree override remove \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra \
    --install kernel-surface \
    --install kernel-surface-core \
    --install kernel-surface-modules \
    --install kernel-surface-modules-core \
    --install kernel-surface-modules-extra

rpm-ostree cleanup -m
ostree container commit

# Install additional Surface support packages
dnf5 install -y \
    iptsd \
    surface-control \
    libwacom-surface \
    surface-secureboot # The password is "surface"

echo ">>> Installing the remaining packages... <<<"

# Installing other packages

dnf5 install libreoffice

# Modifying existing files

echo ">>> Configuring... <<<"

echo "    - org.libreoffice.LibreOffice" >> /etc/bazaar/blocklist.yaml
rm usr/share/applications/Discourse.desktop
rm usr/bin/boot-to-windows
rm usr/share/applications/boot-to-windows.desktop

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
