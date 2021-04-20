#####  Install and configure Helm ########

# Install Helm On Linux

curl -L https://git.io/get_helm.sh | bash -s -- --version v2.16.3


#sudo apt-get install -y nfs-common python-pip

cat << EOF | sudo tee /root/rbac-config.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

kubectl apply -f rbac-config.yaml

# and then update helm instalation to use serviceAccount:

helm init --service-account tiller --upgrade
helm init --service-account tiller --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -
