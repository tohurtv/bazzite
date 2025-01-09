#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

#
sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:org.kde.discover.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \

# Remove packages
 rpm-ostree override remove \
        discover-overlay \
        sunshine \
        lutris \
        input-remapper \
        rom-properties-kf6 \
        fcitx5-mozc \
        fcitx5-chinese-addons \
        fcitx5-chinese-addons-data \
        fcitx5-hangul \
        ptyxis && \
ostree container commit

