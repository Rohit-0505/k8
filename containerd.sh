#containerd
#This section contains the necessary steps to use containerd as CRI runtime.
#Use the following commands to install Containerd on your system:
#Install and configure prerequisites:

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sysctl --system

#Install containerd:
# (Install containerd)
## Set up the repository
### Install packages to allow apt to use a repository over HTTPS
apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

## Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -

## Add Docker apt repository.
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

## Install containerd
apt-get update && sudo apt-get install -y containerd.io

# Configure containerd
mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

echo "runtime-endpoint: unix:///run/containerd/containerd.sock" > /etc/crictl.yaml

# Restart containerd
systemctl restart containerd


#systemd
#To use the systemd cgroup driver in /etc/containerd/config.toml with runc, set

#[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
#  ...
#  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#    SystemdCgroup = true

# Letting iptables see bridged traffic

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

cat <<EOF > /etc/systemd/system/kubelet.service.d/0-containerd.conf
[Service]                                                 
Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF
systemctl daemon-reload

swapoff -a
sysctl net.ipv4.ip_forward=1
sysctl net.bridge.bridge-nf-call-iptables=1


kubeadm init --cri-socket /run/containerd/containerd.sock --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/v3.10/manifests/calico.yaml

#/var/lib/kubelet/config.yaml
#apiVersion: kubelet.config.k8s.io/v1beta1
#kind: KubeletConfiguration
#cgroupDriver: systemd

systemctl daemon-reload
systemctl restart kubelet

kubectl taint node ubuntu node-role.kubernetes.io/master-
