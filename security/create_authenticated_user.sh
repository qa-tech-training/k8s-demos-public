#!/bin/bash
sudo useradd -m -s /bin/bash alice
sudo passwd alice

which openssl || sudo apt-get install openssl

openssl genrsa -out alice.key 2048

touch $HOME/.rnd

openssl req -new \
	-key alice.key \
	-out alice.csr \
	-subj "/CN=alice/O=example-org"

sudo openssl x509 \
	-req -in alice.csr \
	-CA /etc/kubernetes/pki/ca.crt \
	-CAkey /etc/kubernetes/pki/ca.key \
	-CAcreateserial \
	-out alice.crt \
	-days 45

cp ~/.kube/config ~/.kube/config_old
sudo cp alice.crt alice.key /home/alice
sudo chown -R alice:alice /home/alice

kubectl config set-credentials alice \
	--client-certificate=/home/alice/alice.crt \
	--client-key=/home/alice/alice.key

kubectl config set-context alice@kubernetes \
	--cluster=kubernetes \
	--namespace=dev \
	--user=alice

kubectl config delete-context kubernetes-admin@kubernetes
kubectl config delete-user kubernetes-admin 

sudo mkdir /home/alice/.kube
sudo cp ~/.kube/config /home/alice/.kube/config
sudo chown -R alice:alice /home/alice/.kube

rm ~/.kube/config
mv ~/.kube/config_old ~/.kube/config
