#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Add Repos
curl -Lo /etc/yum.repos.d/mullvad.repo https://repository.mullvad.net/rpm/stable/mullvad.repo

# Clean up stuff from Bazzite Upstream
sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:org.kde.discover.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
sed -i '/<entry name="favorites" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,systemsettings.desktop,org.kde.dolphin.desktop,org.kde.kate.desktop,terminal,org.kde.discover.desktop,system-update.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.kickoff/contents/config/main.xml && \
rm /usr/share/kglobalaccel/org.gnome.Ptyxis.desktop && \
sed -i '/^TerminalApplication=kde-ptyxis$/d' /etc/xdg/kdeglobals && \
sed -i '/^TerminalService=org.gnome.Ptyxis.desktop$/d' /etc/xdg/kdeglobals && \
cp /usr/share/applications/org.kde.konsole.desktop /usr/share/kglobalaccel/org.kde.konsole.desktop && \
/usr/libexec/containerbuild/cleanup.sh && \
ostree container commit

# Remove packages
 rpm-ostree override remove \
        discover-overlay \
        sunshine \
        lutris \
        input-remapper \
        rom-properties \
        rom-properties-utils \
        rom-properties-kf6 \
        rom-properties-thumbnailer-dbus \
        rom-properties-common \
        fcitx5 \
        fcitx5-data \
        fcitx5-libs \
        fcitx5-lua \
        fcitx5-qt-qt6gui \
        fcitx5-qt-libfcitx5qt6widgets \
        fcitx5-configtool \
        libime \
        libime-data \
        fcitx5-mozc \
        fcitx5-chinese-addons \
        fcitx5-chinese-addons-data \
        fcitx5-hangul \
        kcharselect \
        kdebugsettings \
        filelight \
        ptyxis && \
/usr/libexec/containerbuild/cleanup.sh && \
ostree container commit

# Install packages
rpm-ostree install \
        konsole \
        playerctl \
        pamixer && \
/usr/libexec/containerbuild/cleanup.sh && \
ostree container commit

# Remove desktop entries
 #rm /usr/share/applications/com.gerbilsoft.rom-properties.rp-config.desktop && \
 rm /usr/share/applications/bazzite-documentation.desktop && \
 rm /usr/share/applications/discourse.desktop && \
 rm /usr/share/applications/sunshine.desktop && \
 /usr/libexec/containerbuild/cleanup.sh && \
 ostree container commit

