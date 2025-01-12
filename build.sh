#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Add Repos
curl -Lo /etc/yum.repos.d/mullvad.repo https://repository.mullvad.net/rpm/stable/mullvad.repo

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
        playerctl \
        flatpak-builder \
        patchelf \
        pamixer && \
/usr/libexec/containerbuild/cleanup.sh && \
ostree container commit

# Enable Bazzite-multilib 
sed -i '/\[copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib\]/,/\[/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
# Install mesa-libOpenCL from bazzite-multilib
rpm-ostree install \
        mesa-libOpenCL && \
/usr/libexec/containerbuild/cleanup.sh && \
ostree container commit

# Fix sddm themes by moving and syncing to /var and symlinking to correct location
# move current location to /usr/share/ublue-os/sddm/themes
mkdir -p "/usr/share/ublue-os/sddm/themes"
mv /usr/share/sddm/themes /usr/share/ublue-os/sddm/
# symlink sync location to default sddm theme location
ln -s /var/sddm/themes /usr/share/sddm/themes
# Create the sddm theme sync script
cat << 'EOF' > "/usr/libexec/sync-sddm-themes"
#!/bin/bash
# Script to sync SDDM themes

SRC_DIR="/usr/share/ublue-os/sddm/themes"
DEST_DIR="/var/sddm/themes"

# Ensure the destination directory exists
mkdir -p "$DEST_DIR"

# Sync themes while preserving permissions and timestamps
rsync -a --delete "$SRC_DIR/" "$DEST_DIR/"

# Exit with status
exit $?
EOF

# Make the sync script executable
chmod +x "/usr/libexec/sync-sddm-themes"

# Create the systemd service
echo "Creating systemd service at /usr/lib/systemd/system/sync-sddm-themes.service..."
cat << EOF > "/usr/lib/systemd/system/sync-sddm-themes.service"
[Unit]
Description=Sync SDDM Themes from /usr/share to /var
Before=sddm.service
ConditionPathExists=/usr/share/ublue-os/sddm/themes

[Service]
Type=oneshot
ExecStart=/usr/libexec/sync-sddm-themes
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

# enable the service
systemctl enable sync-sddm-themes.service

# Disable Bazzite-multilib 
sed -i '/\[copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib\]/,/\[/{s/enabled=1/enabled=0/}' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
/usr/libexec/containerbuild/cleanup.sh && \
ostree container commit

