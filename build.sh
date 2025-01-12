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

# User facing fixes for flatpak and more
# Create the script
cat << 'EOF' > "/usr/libexec/user-fixes"
#!/bin/bash
# Directories
SYSTEM_THEMES="/usr/share/themes"
USER_THEMES="$HOME/.themes"

# Create the ~/.themes directory if it doesn't exist
if [ ! -d "$USER_THEMES" ]; then
    echo "Creating $USER_THEMES directory..."
    mkdir -p "$USER_THEMES"
fi

# Synchronize themes from /usr/share/themes to ~/.themes
echo "Syncing themes from $SYSTEM_THEMES to $USER_THEMES..."
rsync -auv  --exclude="Adwaita*" --exclude="Clearlooks" --exclude="Crux" --exclude="HighContrast" --exclude="Industrial" --exclude="Mist" --exclude="Raleigh" --exclude="ThinIce" "$SYSTEM_THEMES/" "$USER_THEMES/"

# Set the correct permissions for the user directory
echo "Setting correct permissions for $USER_THEMES..."
chown -R "$USER:$USER" "$USER_THEMES"

echo "Sync complete."

# Exit with status
exit $?
EOF

# Make the script executable
chmod +x "/usr/libexec/user-fixes"

# Create the systemd service
echo "Creating systemd service at /usr/lib/systemd/system/sync-sddm-themes.service..."
cat << EOF > "/usr/lib/systemd/user/user-fixes.service"
[Unit]
Description=Configure fixes for current user

[Service]
Type=simple
ExecStart=/usr/libexec/user-fixes

[Install]
WantedBy=default.target
EOF

# enable the service
systemctl --global enable user-fixes.service

# Fix sddm themes by moving and syncing to /var and symlinking to correct location
# move current location to /usr/share/ublue-os/sddm/themes
mkdir -p "/usr/share/ublue-os/sddm"
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
rsync -au "$SRC_DIR/" "$DEST_DIR/"

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

