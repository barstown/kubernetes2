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
talhelper gensecret > talsecret.sops.yaml
# Encrypt the secret with sops: sops -e -i talsecret.sops.yaml
# Generate talconfig.yaml https://budimanjojo.github.io/talhelper/latest/getting-started/
talhelper genconfig
talhelper gencommand apply --extra-flags "--insecure" # optionally append | bash at the end to automate it
talhelper gencommand bootstrap # optionally append | bash at the end to automate it
talhelper gencommand kubeconfig # optionally append | bash at the end to automate it
talosctl --nodes $CONTROL_PLANE_IP --talosconfig=./talosconfig health
kubectl get nodes
```

## Helm installs

Documenting Helm installs here until I get the rest of the Flux deployment set up

### Cilium

```bash
helm install \
    cilium \
    cilium/cilium \
    --version 1.18.4 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=true \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup \
    --set k8sServiceHost=localhost \
    --set k8sServicePort=7445 \
    --set=gatewayAPI.enabled=true \
    --set=gatewayAPI.enableAlpn=true \
    --set=gatewayAPI.enableAppProtocol=true \
    # --set routingMode=native \
    # --set socketLB.hostNamespaceOnly=true
```
