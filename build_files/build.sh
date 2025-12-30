#!/bin/bash

set -ouex pipefail

echo ">>> Installing the Surface Kernel... <<<"

RELEASE="$(rpm -E %fedora)"

# Add the Linux Surface repository
wget https://pkg.surfacelinux.com/fedora/linux-surface.repo -O /etc/yum.repos.d/linux-surface.repo

# Install Surface packages
rpm-ostree override replace \
    --experimental \
    --from repo=linux-surface \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra

# Install additional Surface support packages
dnf5 install -y \
    iptsd \
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
