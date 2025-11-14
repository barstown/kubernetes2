# Helm installs

Documenting Helm installs here until I get the rest of the Flux deployment set up

## Gateway API CRD

https://gateway-api.sigs.k8s.io/guides/?h=crds#installing-gateway-api

```bash
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml
```

## Cilium

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
    --set socketLB.hostNamespaceOnly=true \
    --set l7Proxy=true \
    --set gatewayAPI.enabled=true
```
