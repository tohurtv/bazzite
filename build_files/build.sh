#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Add Repos
curl -Lo /etc/yum.repos.d/mullvad.repo https://repository.mullvad.net/rpm/stable/mullvad.repo
curl -Lo /etc/yum.repos.d/home:tohur:bazzite.repo https://download.opensuse.org/repositories/home:/tohur:/bazzite/Fedora_41/home:tohur:bazzite.repo
# Add Zeroteir Repo
cat << 'EOF' > "/etc/yum.repos.d/zerotier.repo"
[zerotier]
name=ZeroTier, Inc. RPM Release Repository
baseurl=http://download.zerotier.com/redhat/fc/41
enabled=1
gpgcheck=0
EOF
# Clean up stuff from Bazzite Upstream and add sone extra fixes
sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,applications:org.kde.discover.desktop,preferred:\/\/filemanager<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
sed -i '/<entry name="favorites" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/browser,systemsettings.desktop,org.kde.dolphin.desktop,org.kde.kate.desktop,terminal,org.kde.discover.desktop,system-update.desktop<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.kickoff/contents/config/main.xml && \
rm /usr/share/kglobalaccel/org.gnome.Ptyxis.desktop && \
sed -i '/^TerminalApplication=kde-ptyxis$/d' /etc/xdg/kdeglobals && \
sed -i '/^TerminalService=org.gnome.Ptyxis.desktop$/d' /etc/xdg/kdeglobals && \
#sed -i 's/^NoDisplay=true$/NoDisplay=false/' /usr/share/applications/org.kde.konsole.desktop && \
#cp /usr/share/applications/org.kde.konsole.desktop /usr/share/kglobalaccel/org.kde.konsole.desktop && \
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.kde.kdeconnect.app.desktop && \
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.kde.kdeconnect.sms.desktop && \
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.kde.krfb.desktop && \
sed -i 's/^NoDisplay=false$/NoDisplay=true/' /usr/share/applications/waydroid-container-restart.desktop && \
rm /usr/share/applications/bazzite-documentation.desktop && \
rm /usr/share/applications/discourse.desktop && \
rm /usr/share/applications/sunshine.desktop && \
rm /usr/bin/bazzite-steam && \
rm /usr/bin/bazzite-steam-bpm && \
rm /usr/share/applications/bazzite-steam-bpm.desktop && \
#cp /usr/share/applications/steam.desktop /usr/share/applications/steam-bk.desktop && \
#cp /usr/share/icons/hicolor/256x256/apps/steam.png /usr/share/icons/hicolor/256x256/apps/steam-bk.png && \

#swap back to pulseaudio
dnf5 swap -y --allowerasing pipewire-pulseaudio pulseaudio
dnf5 install -y pulseaudio-libs

dnf5 remove -y \
       discover-overlay \
       sunshine \
       lutris \
       steam \
       steam-device-rules \
       input-remapper \
       rom-properties \
       rom-properties-utils \
       rom-properties-kf6 \
       rom-properties-thumbnailer-dbus \
       rom-properties-common \
       kcharselect \
       kdebugsettings \
       kfind \
       kjournald \
       kwrite \
       fcitx5 \
       fcitx5-mozc \
       waydroid \
       waydroid-selinux \
       filelight \
       ptyxis

# Install packages
dnf5 install -y \
       playerctl \
       gamemode \
       cabextract \
       fwupd \
       fwupd-efi \
       flatpak-builder \
       gperftools-libs \
       libglvnd-glx \
       python3.11 \
       plasma-browser-integration \
       konsole \
       konsole-part \
       nodejs \
       nodejs-npm \
       libaio-devel \
       espeak-ng \
       ffmpeg \
       gcc \
       g++ \
       git-lfs \
       v4l-utils \
       wine-core \
       wine-core.i686 \
       zerotier-one \
       python3-protobuf \
       patchelf \
       pamixer

dnf5 install -y --no-gpgchecks \
       mesa-libOpenCL

# User facing fixes for flatpak and more
# Create the script
# Write the content to the file
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
rsync -auv --exclude="Adwaita*" --exclude="Clearlooks" --exclude="Crux" --exclude="HighContrast" --exclude="Industrial" --exclude="Mist" --exclude="Raleigh" --exclude="ThinIce" "$SYSTEM_THEMES/" "$USER_THEMES/"

# Set the correct permissions for the user directory
echo "Setting correct permissions for $USER_THEMES..."
chown -R "$USER:$USER" "$USER_THEMES"

echo "Sync complete."

# Path to the marker file
MARKER_FILE="$HOME/.config/user-fixes-done"

# Check if the marker file exists
if [[ -f "$MARKER_FILE" ]]; then
    echo "Fixes already applied. Exiting."
    exit 0
else
    echo "Fixes not found. Applying fixes..."

    # Add your commands here
    echo "Running your commands..."

    #Install Steam and Lutris flatpaks
    flatpak install -y com.valvesoftware.Steam
    flatpak install -y net.lutris.Lutris

    # Apply global flatpak overrides for user
    mkdir -p "$HOME/.local/share/flatpak/overrides"
cat << EOT > "$HOME/.local/share/flatpak/overrides/global"
[Context]
filesystems=xdg-run/udev:ro;~/Games;~/.icons:ro;xdg-config/gtk-3.0;~/.config/gtk-3.0:ro;~/.config/gtk-4.0:ro;~/.themes:ro;~/.fonts:ro;~/.local/share/fonts:ro;/var/mnt;/run/media
EOT

cat << EOT > "$HOME/.config/pulse/default.pa"
.include /etc/pulse/default.pa
.nofail
unload-module module-suspend-on-idle
.fail
EOT

cat << EOT > "$HOME/.config/pulse/daemon.conf"
.include /etc/pulse/daemon.conf
default-sample-rate = 48000
EOT
    pulseaudio -k
    
    # Create the marker file
    touch "$MARKER_FILE"
    echo "Fixes applied. Marker file created at $MARKER_FILE."
fi

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

# Create the steam wrapper for flatpak
echo "Creating steam wrapper at /usr/bin/steam..."
cat << 'EOF' > "/usr/bin/steam"
#!/bin/bash

# Check if Steam Flatpak is installed
if flatpak info com.valvesoftware.Steam &>/dev/null; then
    flatpak run com.valvesoftware.Steam "$@"
else
    # Prompt user using yad
    yad --title="Steam Flatpak Not Installed" \
        --button=Yes:0 --button=No:1 \
        --center \
        --text="Steam (Flatpak) is not installed.\n\nDo you want to install it now?"

    # Check exit code from yad
    if [ $? -eq 0 ]; then
        # Open Discover or GNOME Software via AppStream URI
        xdg-open "appstream://com.valvesoftware.Steam"
    fi
fi
EOF


# Make the steam wrapper executable
chmod +x "/usr/bin/steam"

# Move steam.desktop and steam.png to proper locations
#mv /usr/share/applications/steam-bk.desktop /usr/share/applications/steam.desktop && \
#mv /usr/share/icons/hicolor/256x256/apps/steam-bk.png /usr/share/icons/hicolor/256x256/apps/steam.png && \
#/usr/libexec/containerbuild/cleanup.sh && \
#ostree container commit

# Make the steam.desktop executable
#chmod +x "/usr/share/applications/steam.desktop"
