#!/bin/bash

set -ouex pipefail

# Remove packages
#dnf5 remove -y \
       #discover-overlay \

# Install packages
dnf5 install -y \
       rocminfo \
       rocm-opencl \
       rocm-clinfo \
       rocm-hip
