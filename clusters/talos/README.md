# Talos cluster

https://www.talos.dev/v1.11/introduction/getting-started

This Talos cluster was initialized by and is maintained using
[Talhelper](https://github.com/budimanjojo/talhelper), a tool to manage Talos
cluster in your GitOps repository. It's like Kustomize but for Talos manifest
files with SOPS support natively.

You can interact with the cluster using traditional `talosctl` commands, or use
`talhelper gencommand` to perform most standard `talosctl` commands with the the
appropriate flags, nodes, and endpoint options automatically.

## Talos Factory image

A customized image was generated with SecureBoot support and additional
packages, using the Talos Factory website, for the initial VM setup. Next
`talhelper` uses the extensions defined in the
[talconfig.yaml](./talconfig.yaml) to generate the schematic ID for the final
deployments automatically.

[https://factory.talos.dev/](https://factory.talos.dev/)

Extensions added:

```yml
customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/qemu-guest-agent
```

## Cluster initialization

### Talhelper config and deployment

```bash
talhelper gensecret > talsecret.sops.yaml
# Encrypt the secret with sops: sops -e -i talsecret.sops.yaml
# Generate talconfig.yaml https://budimanjojo.github.io/talhelper/latest/getting-started/
talhelper genconfig
talhelper gencommand apply --extra-flags "--insecure" # optionally append | bash to automate it
talhelper gencommand bootstrap # optionally append | bash to automate it
talhelper gencommand kubeconfig # optionally append | bash to automate it
talhelper gencommand health # optionally append | bash to automate it
kubectl get nodes
```

### Helm installs

Documenting Helm installs here until I get the rest of the Flux deployment set
up

#### Cilium CNI

```bash
helm upgrade --install \
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

### FluxCD

Application and infrastructure deployments are automated using
[Flux](https://github.com/fluxcd/flux2) as an alternative to more complex
setups.

Initial configuration of Flux is completed as follows:

Install:

`brew install fluxcd/tap/flux`

Bootstrap:
```bash
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=barstown
flux bootstrap github \
  --token-auth \
  --owner=$GITHUB_USER \
  --repository=kubernetes2 \
  --branch=main \
  --path=clusters/talos \
  --personal
```

### Cluster maintenance

Update [talconfig.yaml](./talconfig.yaml) as needed. Run `talhelper genconfig`
to create new node config files, and then run apply/upgrade/upgrade-k8s as
needed for ongoing maintenance.

```bash
talhelper genconfig
talhelper gencommand apply # optionally append | bash to automate it
talhelper gencommand upgrade # optionally append | bash to automate it
talhelper gencommand upgrade-k8s # optionally append | bash to automate it
```
