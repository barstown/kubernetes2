#!/bin/bash
set -e

# Sudo required
REQUIRES_SUDO=true

DEBIAN_FRONTEND=noninteractive
PKG_MGR=apt

# List of packages to install
PACKAGES=(
    age
)

# Get the latest SOPS version from GitHub API
SOPS_VERSION=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')

: "${PKG_MGR:?PKG_MGR is not set}"
: "${PACKAGES:?PACKAGES is not set}"
: "${SOPS_VERSION:?SOPS_VERSION is not set}"

ARCH=$(uname -m) && \
  if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi && \
  if [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi && \
  echo "Architecture: $ARCH"

# Update and install packages
${PKG_MGR} update && \
${PKG_MGR} -y full-upgrade && \
${PKG_MGR} install -y "${PACKAGES[@]}"

# Clean up steps
${PKG_MGR} autoclean -y && \
${PKG_MGR} autoremove -y --purge && \
rm -Rf /var/cache/apt/archives

echo "Installing SOPS ${SOPS_VERSION}..."
curl -Lo /usr/local/bin/sops \
    https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${ARCH}
chown root:root /usr/local/bin/sops
chmod 755 /usr/local/bin/sops

unset DEBIAN_FRONTEND
