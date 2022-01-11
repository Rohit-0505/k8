# Install go
wget https://dl.google.com/go/go1.17.6.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz

cat << EOF | sudo tee /root/.profile
export PATH=$PATH:/usr/local/go/bin
EOF

source /root/.profile


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

cat << EOF | sudo tee /root/.okta_aws_login_config
[DEFAULT]
okta_org_url = https://nike.okta.com
okta_auth_server = aus27z7p76as9Dz0H1t7
client_id = 0oa34x20aq50blCCZ1t7
gimme_creds_server = https://api.sec.nikecloud.com/gimmecreds/accounts
aws_appname = AWS WaffleIron Multi-Account
aws_rolename = all
write_aws_creds = True
cred_profile = acc-role
okta_username = <YOUR_NIKE_EMAIL>@nike.com
app_url =
resolve_aws_alias = False
include_path = False
preferred_mfa_type = push
remember_device = True
aws_default_duration = 43200
device_token =
output_format = export
EOF
