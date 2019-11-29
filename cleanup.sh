sudo docker stop armada

sudo docker rm armada

sudo docker run -d --net host -p 8000:8000 --name armada \
    -v ~/.kube/config:/armada/.kube/config quay.io/airshipit/armada:latest-ubuntu_bionic
