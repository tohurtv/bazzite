# Bazzite

# Purpose

This repository is a fine tuned [Bazzite](https://bazzite.gg/) image with what I consider bloat apps removed and instead the apps that can be used as flatpaks where it makes sense are. I will be adding tweaks to make flatpak work better by default such as adding the proper overrides and theme syncing so flatpak apps match the rest of the system. Can see the changes I make to the images [here](https://github.com/tohurtv/bazzite/blob/main/build.sh)

# how to use

For AMD/Intel rebase using:

```
    rpm-ostree rebase ostree-unverified-registry:ghcr.io/tohurtv/bazzite:latest
```
For Nvidia rebase using:

```
    rpm-ostree rebase ostree-unverified-registry:ghcr.io/tohurtv/bazzite-nvidia:latest
```