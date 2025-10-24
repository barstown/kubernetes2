# Talos

https://www.talos.dev/v1.11/introduction/getting-started

This Talos cluster was initialized and is maintained using
[Talm](https://github.com/cozystack/talm), enabling management of Talos through
GitOps practices.

While you can interact with the cluster using traditional `talosctl` commands,
it is recommended to handle upgrades and some other opterations via `talm`.

## Talos Factory Image

A custom Talos Factory image was generated with SecureBoot support and
additional packages and drivers included, using the Talos Factory website:

[https://factory.talos.dev/](https://factory.talos.dev/)

Packages and extensions added:

- Secureboot

```yml
customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/drbd
            - siderolabs/iscsi-tools
            - siderolabs/nfsd
            - siderolabs/qemu-guest-agent
            - siderolabs/zfs
```

The schematic ID of this image is:
- 06bf98081ab80adce0d2e924dc3ec3e4f249bd8035933d99646e284ccb26511b

## Initialization

The cluster configuration was generated using the `cozystack` profile in `talm`.
This profile’s default templating provides enhanced features. (A `generic`
profile is also available.)

To initialize:

```bash
talm init -p cozystack
```

After the directory structure is created, the `templates/_helpers.tpl` file was
modified to include additional options such as `inlineManifests` for automatic
Cilium deployment. This customization may be removed in future versions.

The critical next step is to edit `values.yaml` by specifying the full image
name generated via Talos Factory and network configuration details such as the
floating VIP (provided by the `cozystack` profile). The Cilium Helm template
output should be included under `inlineManifests`.

To bootstrap a Talos VM node, obtain its IP address and run the following:

```bash
talm -n 1.2.3.4 -e 1.2.3.4 template -t templates/controlplane.yaml -i > nodes/node1.yaml
```

After defining node configurations, apply them and start the installation:

```bash
talm apply -f nodes/node1.yaml -i
```

If successful, Talos installs to disk, applies the configuration, and reboots.
After a short wait, the node’s status should report as Healthy.

## Upgrading Talos

When upgrading to a new Talos version:

1. Generate a new Factory image, ensuring previous customizations are preserved.
2. Update `values.yaml` with the new image and any relevant changes.
3. Re-template your node configurations:

```bash
talm template -f nodes/node1.yaml -I
```

4. Upgrade nodes individually:

```bash
talm upgrade -f nodes/node1.yaml
```

## Upgrading Kubernetes

Refer to the official Kubernetes upgrade
[guide](https://docs.siderolabs.com/kubernetes-guides/advanced-guides/upgrading-kubernetes)
at Sidero Labs:

After all nodes have been updated and deployments validated against the new
Kubernetes version, proceed to upgrade Kubernetes itself.

It is recommended to perform a dry-run first:

```bash
talosctl --nodes <controlplanene node> --endpoints <endpoint ip> upgrade-k8s --to 1.34.1 --dry-run
```

If the dry-run outputs no issues, execute the actual upgrade:

```bash
talosctl --nodes <controlplanene node> --endpoints <endpoint ip> upgrade-k8s --to 1.34.1
```

## ARCHIVE

### Initial Installation

For the initial installation of Talos Linux (not applicable for disk image
boot), add the following installer image to the machine configuration:

`factory.talos.dev/metal-installer-secureboot/[schematic id]:v1.11.3`

### Upgrading Talos Linux

To upgrade Talos Linux on the machine, use the following image:

`factory.talos.dev/metal-installer-secureboot/[schematic id]:v1.11.3`

## First install

With the customized installer and schematic ID above, installation can proceed
with the following command.

```
talosctl gen config k8s https://10.0.10.41:6443 \
--install-image=factory.talos.dev/metal-installer-secureboot/[schematic id]:v1.11.3 \
--install-disk=/dev/sda
```

Once the config has been generated with the above, proceed to apply to nodes.

`talosctl -n <IP> apply-config --insecure -f controlplane.yaml`

`talosctl -n <IP> apply-config --insecure -f worker.yaml`

Once the controlplane.yaml has been applied to all nodes (if doing multiple
then a loadbalancer must be in front of them. That is the "endpoint").

```
talosctl bootstrap --nodes 10.0.10.x --endpoints 10.0.10.x \
--talosconfig=./talosconfig
```

Now get your kubeconfig for the control plane.

```
talosctl kubeconfig talos-kubeconfig --nodes 10.0.10.x --endpoints 10.0.10.x \
--talosconfig=./talosconfig
```

Verify things are running and the cluster is healthy by running

`kubectl get pods`

or

`kubectl --kubeconfig=talos-kubeconfig get pods -A`
