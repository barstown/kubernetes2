# Talos

https://www.talos.dev/v1.11/introduction/getting-started

This Talos cluster was initialized and is maintained using
[Talhelper](https://github.com/budimanjojo/talhelper), a tool to manage Talos
cluster in your GitOps repository. It's like Kustomize but for Talos manifest
files with SOPS support natively.

While you can interact with the cluster using traditional `talosctl` commands,
it is recommended to handle upgrades and some other opterations via `talm`.

## Talos Factory Image

A custom Talos Factory image was generated with SecureBoot support and
additional packages and drivers included, using the Talos Factory website:

[https://factory.talos.dev/](https://factory.talos.dev/)

Packages and extensions added:

```yml
customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/intel-ucode
            - siderolabs/iscsi-tools
            - siderolabs/nfsd
            - siderolabs/qemu-guest-agent
            - siderolabs/zfs
            # - siderolabs/nonfree-kmod-nvidia-production
            # - siderolabs/nvidia-container-toolkit-production
```

The schematic ID of this image is:
- 4188ec499086246e62f8012f63310e1da2c8ddc9b954b93d86e303d44aaf5ed5

## Initialization

### Using Talhelper
```bash
# Generate talconfig.yaml https://budimanjojo.github.io/talhelper/latest/getting-started/
talhelper gensecret > talsecret.sops.yaml
# Encrypt the secret with sops: sops -e -i talsecret.sops.yaml
talhelper genconfig
talhelper gencommand apply --extra-flags "--insecure" # optionally append | bash at the end to automate it
talhelper gencommand bootstrap # optionally append | bash at the end to automate it

talosctl kubeconfig --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig
talosctl --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig health
kubectl get nodes
```
