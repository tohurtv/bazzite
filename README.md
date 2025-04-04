# Bazzite

# Purpose

This repository is a fine tuned [Bazzite](https://bazzite.gg/) image with what I consider bloat apps removed and instead the apps that can be used as flatpaks where it makes sense are. I will be adding tweaks to make flatpak work better by default such as adding the proper overrides and theme syncing so flatpak apps match the rest of the system. I will be moving this image over to bootc once bootc has package layering. Can see the changes I make to the images [here](https://github.com/tohurtv/bazzite/blob/main/build.sh)

# Added tweaks and/or fixes
- Added ablity to install custom sddm themes by moving them to /var/sddm/themes and then symlinking to /usr/share/sddm/themes.
- Syncing system themes from /usr/share/themes to $HOME/.themes and added flatpak overrides for GTK theme matching.
- Added various flatpak overrides for better overall user experience.
- Steam (wrapper included in /usr/bin so .desktop files work) and Lutris should be installed from Flatpak as they are removed from the image

# how to use

For AMD/Intel rebase using:

```
    rpm-ostree rebase ostree-unverified-registry:ghcr.io/tohurtv/bazzite:latest
```
For Nvidia rebase using:

```
    rpm-ostree rebase ostree-unverified-registry:ghcr.io/tohurtv/bazzite-nvidia:latest
```
