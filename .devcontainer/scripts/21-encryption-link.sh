#!/bin/bash
set -e

AGEKEY_SRC="${HOST_HOME}/.config/sops/age/keys.txt"
AGEKEY_DEST="${HOME}/.config/sops/age/keys.txt"

mkdir -p "${HOME}/.config/sops/age" || true

# Create symbolic link for .config/sops/age if it exists
if [ -f "$AGEKEY_SRC" ]; then
    echo "Creating symbolic link from $AGEKEY_SRC to $AGEKEY_DEST"
    ln -sfn "$AGEKEY_SRC" "$AGEKEY_DEST"
else
    echo "Source directory $AGEKEY_SRC does not exist. Skipping symlink creation."
fi
