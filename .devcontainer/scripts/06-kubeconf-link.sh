#!/bin/bash
set -e

KUBECONF_SRC="${HOST_HOME}/.kube/config"
KUBECONF_DEST="${HOME}/.kube/config"

mkdir -p "${HOME}/.kube" || true
mkdir -p "${HOME}/.zsh" || true
kubectl completion zsh > "${HOME}/.zsh/kubernetes.sh"

# Create symbolic link for .kube if it exists
if [ -f "$KUBECONF_SRC" ]; then
    echo "Creating symbolic link from $KUBECONF_SRC to $KUBECONF_DEST"
    ln -sfn "$KUBECONF_SRC" "$KUBECONF_DEST"
else
    echo "Source directory $KUBECONF_SRC does not exist. Skipping symlink creation."
fi
