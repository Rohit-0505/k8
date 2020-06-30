# Get the Docker gpg key:

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repository:

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Get the Kubernetes gpg key:

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Add the Kubernetes repository:

cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Update your packages:

sudo apt-get update

# Install Docker, kubelet, kubeadm, and kubectl:

sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu kubelet=1.15.3-00 kubeadm=1.15.3-00 kubectl=1.15.3-00

# Hold them at the current version:

sudo apt-mark hold docker-ce kubelet kubeadm kubectl

# Add the iptables rule to sysctl.conf :

echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf

# Enable iptables immediately:

sudo sysctl -p

###########  ON MASTER ONLY  ###########

# Initialize the cluster (run only on the master):

sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Set up local kubeconfig:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply Flannel CNI network overlay:
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# sudo kubectl apply -f https://docs.projectcalico.org/v3.10/manifests/calico.yaml


#Join the worker nodes to the cluster:
# kubeadm join [your unique string from the kubeadm init command]
#Verify the worker nodes have joined the cluster successfully:

sleep 10

kubectl get nodes


######  Install and configure Helm ########

## Install Helm On Linux
#
#curl -L https://git.io/get_helm.sh | bash -s -- --version v2.14.3
#
#
#kubectl taint node ubuntu node-role.kubernetes.io/master-
##kubectl label nodes --all openstack-control-plane=enabled
##kubectl label nodes --all ucp-control-plane=enabled
#kubectl label nodes --all openstack-compute-node=enabled
#
#sudo apt-get install -y nfs-common python-pip
#
#cat << EOF | sudo tee /home/bala/rbac-config.yaml
#apiVersion: v1
#kind: ServiceAccount
#metadata:
#  name: tiller
#  namespace: kube-system
#---
#apiVersion: rbac.authorization.k8s.io/v1
#kind: ClusterRoleBinding
#metadata:
#  name: tiller
#roleRef:
#  apiGroup: rbac.authorization.k8s.io
#  kind: ClusterRole
#  name: cluster-admin
#subjects:
#  - kind: ServiceAccount
#    name: tiller
#    namespace: kube-system
#EOF
#
#kubectl apply -f rbac-config.yaml
#
## and then update helm instalation to use serviceAccount:
#
#helm init --service-account tiller --upgrade
# helm init --service-account tiller --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -
