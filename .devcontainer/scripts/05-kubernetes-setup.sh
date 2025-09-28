#!/bin/bash
set -e

# Sudo required
REQUIRES_SUDO=true

USERNAME=vscode
HELM_VERSION=3.18.4
K9S_VERSION=0.50.9
KUBECOLOR_VERSION=0.5.1
KUBECTL_VERSION=1.33.2
KUBESEAL_VERSION=0.30.0
SKAFFOLD_VERSION=2.16.1

# Ensure required environment variables are set
: "${HELM_VERSION:?HELM_VERSION is not set}"
: "${K9S_VERSION:?K9S_VERSION is not set}"
: "${KUBECOLOR_VERSION:?KUBECOLOR_VERSION is not set}"
: "${KUBECTL_VERSION:?KUBECTL_VERSION is not set}"
: "${KUBESEAL_VERSION:?KUBESEAL_VERSION is not set}"
: "${SKAFFOLD_VERSION:?SKAFFOLD_VERSION is not set}"

ARCH=$(uname -m) && \
  if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; fi && \
  if [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi && \
  echo "Architecture: $ARCH"

echo "Installing Skaffold ${SKAFFOLD_VERSION}..."
curl -Lo /usr/local/bin/skaffold \
    https://github.com/GoogleContainerTools/skaffold/releases/download/v${SKAFFOLD_VERSION}/skaffold-linux-${ARCH}
chmod 755 /usr/local/bin/skaffold

echo "Installing Kubectl ${KUBECTL_VERSION}..."
curl -Lo /usr/local/bin/kubectl \
    https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl
chown root:root /usr/local/bin/kubectl
chmod 755 /usr/local/bin/kubectl

echo "Installing Kubecolor ${KUBECOLOR_VERSION}..."
curl -Lo /tmp/kubecolor.tar.gz \
    https://github.com/kubecolor/kubecolor/releases/download/v${KUBECOLOR_VERSION}/kubecolor_${KUBECOLOR_VERSION}_linux_${ARCH}.tar.gz
tar -xzvf /tmp/kubecolor.tar.gz -C /usr/local/bin kubecolor
chown root:root /usr/local/bin/kubecolor
chmod 755 /usr/local/bin/kubecolor
rm -Rf /tmp/kubecolor.tar.gz

echo "Installing Helm ${HELM_VERSION}..."
curl -Lo /tmp/helm.tar.gz \
    https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz
tar --strip-components=1 -xzvf /tmp/helm.tar.gz -C /usr/local/bin linux-${ARCH}/helm
chown root:root /usr/local/bin/helm
chmod 755 /usr/local/bin/helm
rm -Rf /tmp/helm.tar.gz

echo "Installing Kubeseal ${KUBESEAL_VERSION}..."
curl -Lo /tmp/kubeseal.tar.gz \
    https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-${ARCH}.tar.gz
tar -xzvf /tmp/kubeseal.tar.gz -C /usr/local/bin kubeseal
chown root:root /usr/local/bin/kubeseal
chmod 755 /usr/local/bin/kubeseal
rm -Rf /tmp/kubeseal.tar.gz

echo "Installing k9s ${K9S_VERSION}..."
curl -Lo /tmp/k9s.tar.gz \
    https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz
tar -xzvf /tmp/k9s.tar.gz -C /usr/local/bin k9s
chown root:root /usr/local/bin/k9s
chmod 755 /usr/local/bin/k9s
rm -Rf /tmp/k9s.tar.gz
