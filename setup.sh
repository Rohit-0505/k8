# Install pip3
apt update 
apt install python3-pip


# Install kubelet
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl


## Install Terraform
# Register HashiCorp GPG keys
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt install curl
# Add HashiCorp package repository
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update
sudo apt install terraform
terraform -v


# Install & Configure gimme-aws-creds
pip3 install --upgrade gimme-aws-creds

