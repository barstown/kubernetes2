# Talos

https://www.talos.dev/v1.9/introduction/getting-started/

## Custom image

A custom image was generted with support for SecureBoot as well as installing
several other packages and drivers using the Talos Factory website.

https://factory.talos.dev/

## My image tweaks

Packages and options added:

- Secureboot

```yml
customization:
  systemExtensions:
    officialExtensions:
      - siderolabs/iscsi-tools
      # - siderolabs/nonfree-kmod-nvidia-production
      # - siderolabs/nvidia-container-toolkit-production
      - siderolabs/qemu-guest-agent
```

Your image schematic ID is: 
- 4392dfdeec70a2d7f294c51508ac5b05977272ae5a2ea7c0c0b5288e0e34317d # with nvidia components
- dc7b152cb3ea99b821fcb7340ce7168313ce393d663740b791c36f6e95fc8586 # without nvidia components

### Initial Installation

For the initial installation of Talos Linux (not applicable for disk image boot), add the following installer image to the machine configuration:

`factory.talos.dev/installer-secureboot/[schematic id]:v1.9.4`

### Upgrading Talos Linux

To upgrade Talos Linux on the machine, use the following image:

`factory.talos.dev/installer-secureboot/[schematic id]:v1.9.4`

## First install

With the customized installer and schematic ID above, installation can proceed
with the following command.

talosctl gen config k8s https://10.0.10.125:6443 \
--install-image=factory.talos.dev/installer-secureboot/[schematic id]:v1.9.4 \
--install-disk=/dev/sda

Once the config has been generated with the above, proceed to apply to nodes.

talosctl -n <IP> apply-config --insecure -f controlplane.yaml

talosctl -n <IP> apply-config --insecure -f worker.yaml

Once the controlplane.yaml has been applied to all nodes (if doing multiple
then a loadbalancer must be in front of them. That is the "endpoint").

talosctl bootstrap --nodes 10.0.10.x --endpoints 10.0.10.x \
--talosconfig=./talosconfig

Now get your kubeconfig for the control plane.

talosctl kubeconfig talos-kubeconfig --nodes 10.0.10.x --endpoints 10.0.10.x \
--talosconfig=./talosconfig

Verify things are running and the cluster is healthy by running

kubectl get pods

or

kubectl --kubeconfig=talos-kubeconfig get pods -A
