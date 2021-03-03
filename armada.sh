#!/bin/bash
set -xe

# Set permissions o+r, beacause these files need to be readable
# for Armada in the container
KUBE_CONFIG_PERMISSIONS=$(stat --format '%a' ~/.kube/config)

sudo chmod 0644 ~/admin.conf

export KUBECONFIG="$HOME/admin.conf"
# In the event that this docker command fails, we want to continue the script
# and reset the file permissions.
set +e

# check tiller service type (ClusterIP or NodePort)
tiller_service=$(kubectl get svc -n kube-system -o wide | awk '/tiller/ {print $2}')

# Update tiller service to NodePort
if [ $tiller_service != 'NodePort' ]
then
  kubectl get svc tiller-deploy -n kube-system  -o yaml > /tmp/tiller-clusterip-service-backup.yaml
  cp /tmp/tiller-clusterip-service-backup.yaml /tmp/tiller-nodeport.yaml
  sed -i 's/ClusterIP/NodePort/g' /tmp/tiller-nodeport.yaml
  kubectl apply -f /tmp/tiller-nodeport.yaml
  sleep 5
else
  echo 'NodePort service is already created for tiller.'
fi

# Get the tiller Port
tiller_port=$(kubectl get svc -n kube-system -o wide | awk '/tiller/ {print $5}' | cut -c7-11)
#tiller_ip=$(kubectl get pods -n kube-system -o wide | awk '/tiller/ {print $6}')
tiller_ip=32.68.220.14

# add tiller ip to no_proxy
export no_proxy=$no_proxy,$tiller_ip
http_proxy=http://one.proxy.att.com:8888
https_proxy=http://one.proxy.att.com:8888
# Download latest Armada image and deploy Airship components
docker run --rm --net host -p 8000:8000 --name armada \
    -v ~/.kube/config:/armada/.kube/config \
    -v "$(pwd)"/divingbell.yaml:/divingbell.yaml \
    -e http_proxy=$http_proxy \
    -e https_proxy=$https_proxy \
    -e no_proxy=$no_proxy \
    quay.io/airshipit/armada:latest-ubuntu_bionic \
    apply /divingbell.yaml --tiller-host $tiller_ip  --tiller-port $tiller_port

# Set back permissions of the files
unset KUBECONFIG
sudo chmod "${KUBE_CONFIG_PERMISSIONS}" ~/admin.conf
