#!/bin/bash

SERVICEACCOUNT_TOKEN=$(kubectl get secrets -n=kube-system -o json | jq -r '.items[]|select(.metadata.annotations."kubernetes.io/service-account.name"=="multus")| .data.token' | base64 -d )
KUBERNETES_SERVER="$(awk '/server/ { print $2 }' /etc/kubernetes/kubelet.kubeconfig)"

cat > multus.kubeconfig <<EOF
apiVersion: v1
kind: Config
clusters:
- name: local
  cluster:
    server: ${KUBERNETES_SERVER}
    certificate-authority: /etc/kubernetes/ssl/ca-kubernetes.crt
users:
- name: multus
  user:
    token: "${SERVICEACCOUNT_TOKEN}"
contexts:
- name: multus-context
  context:
    cluster: local
    user: multus
current-context: multus-context
EOF
