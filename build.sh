#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Add and enable repos Repos
curl -Lo /etc/yum.repos.d/mullvad.repo https://repository.mullvad.net/rpm/stable/mullvad.repo
# Enable Rpm-fusion
sed -i '/\[rpmfusion-free\]/,/\[/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/rpmfusion-free.repo && \
sed -i '/\[rpmfusion-free-updates\]/,/\[/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/rpmfusion-free-updates.repo && \
# Enable Bazzite-multilib 
sed -i '/\[copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib\]/,/\[/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \

# Clean up stuff from Bazzite Upstream and add sone extra fixes
sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:org.kde.discover.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
sed -i '/<entry name="favorites" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,systemsettings.desktop,org.kde.dolphin.desktop,org.kde.kate.desktop,terminal,org.kde.discover.desktop,system-update.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.kickoff/contents/config/main.xml && \
rm /usr/share/kglobalaccel/org.gnome.Ptyxis.desktop && \
sed -i '/^TerminalApplication=kde-ptyxis$/d' /etc/xdg/kdeglobals && \
sed -i '/^TerminalService=org.gnome.Ptyxis.desktop$/d' /etc/xdg/kdeglobals && \
cp /usr/share/applications/org.kde.konsole.desktop /usr/share/kglobalaccel/org.kde.konsole.desktop && \
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.kde.kdeconnect.app.desktop && \
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.kde.kdeconnect.sms.desktop && \
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.kde.krfb.desktop && \
#sed -i 's/^NoDisplay=false$/NoDisplay=true/' /usr/share/applications/bazzite-documentation.desktop && \
#sed -i 's/^NoDisplay=false$/NoDisplay=true/' /usr/share/applications/discourse.desktop && \
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/sunshine.desktop && \
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
        chromium-libs-media-freeworld \
        flatpak-builder \
        libxcrypt-compat \
        apr \
        apr-util \
        dbus-libs \
        glx-utils \
        libglvnd-egl \
        libglvnd-glx \
        libICE \
        librsvg2 \
        libSM \
        libxcrypt-compat \
        libXcursor \
        libXfixes \
        libXi \
        libXinerama \
        libxkbcommon-x11 \
        libXrandr \
        libXtst \
        libXxf86vm \
        lshw \
        mtdev \
        mesa-libOpenCL \
        xcb-util \
        xcb-util-cursor \
        xcb-util-image \
        xcb-util-keysyms \
        xcb-util-renderutil \
        xcb-util-wm \
        patchelf \
        pamixer && \
/usr/libexec/containerbuild/cleanup.sh && \
ostree container commit

# Disable Rpm-fusion
sed -i '/\[rpmfusion-free\]/,/\[/{s/enabled=1/enabled=0/}' /etc/yum.repos.d/rpmfusion-free.repo && \
sed -i '/\[rpmfusion-free-updates\]/,/\[/{s/enabled=1/enabled=0/}' /etc/yum.repos.d/rpmfusion-free-updates.repo && \       
# Disable Bazzite-multilib 
sed -i '/\[copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib\]/,/\[/{s/enabled=1/enabled=0/}' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
/usr/libexec/containerbuild/cleanup.sh && \
ostree container commit

