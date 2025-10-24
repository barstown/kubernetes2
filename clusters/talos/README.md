# Talos

https://www.talos.dev/v1.9/introduction/getting-started/

## Custom image

A custom image was generated with support for SecureBoot as well as installing
several other packages and drivers using the Talos Factory website.

https://factory.talos.dev/

## My image tweaks

Packages and options added:

- Secureboot

```yml
customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/drbd
            - siderolabs/iscsi-tools
            - siderolabs/nfsd
            - siderolabs/qemu-guest-agent
```

Your image schematic ID is:
- d14e88852c7d01149a17c3200ab4be572a3689261d5baa132522527824b5baa7

### Initial Installation

For the initial installation of Talos Linux (not applicable for disk image boot), add the following installer image to the machine configuration:

`factory.talos.dev/metal-installer-secureboot/[schematic id]:v1.11.3`

### Upgrading Talos Linux

To upgrade Talos Linux on the machine, use the following image:

`factory.talos.dev/metal-installer-secureboot/[schematic id]:v1.11.3`

## First install

With the customized installer and schematic ID above, installation can proceed
with the following command.

talosctl gen config k8s https://10.0.10.125:6443 \
--install-image=factory.talos.dev/metal-installer-secureboot/[schematic id]:v1.11.3 \
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
