#!/bin/bash
if [[ -z $K8SUSER ]]; then
    echo "YOU DIDN'T SET K8SUSER, DUMMY"
    exit 1
fi

sudo useradd -m -s /bin/bash $K8SUSER
sudo passwd $K8SUSER

which openssl || sudo apt-get install openssl

openssl genrsa -out $K8SUSER.key 2048

touch $HOME/.rnd

openssl req -new \
	-key $K8SUSER.key \
	-out $K8SUSER.csr \
	-subj "/CN=$K8SUSER/O=example-org"

sudo openssl x509 \
	-req -in $K8SUSER.csr \
	-CA /etc/kubernetes/pki/ca.crt \
	-CAkey /etc/kubernetes/pki/ca.key \
	-CAcreateserial \
	-out $K8SUSER.crt \
	-days 45

cp ~/.kube/config ~/.kube/config_old
sudo cp $K8SUSER.crt $K8SUSER.key /home/$K8SUSER
sudo chown -R $K8SUSER:$K8SUSER /home/$K8SUSER

kubectl config set-credentials $K8SUSER \
	--client-certificate=/home/$K8SUSER/$K8SUSER.crt \
	--client-key=/home/$K8SUSER/$K8SUSER.key

kubectl config set-context $K8SUSER@kubernetes \
	--cluster=kubernetes \
	--namespace=dev \
	--user=$K8SUSER

kubectl config use-context $K8SUSER@kubernetes

kubectl config delete-context kubernetes-admin@kubernetes
kubectl config delete-user kubernetes-admin 

sudo mkdir /home/$K8SUSER/.kube
sudo cp ~/.kube/config /home/$K8SUSER/.kube/config
sudo chown -R $K8SUSER:$K8SUSER /home/$K8SUSER/.kube

rm ~/.kube/config
mv ~/.kube/config_old ~/.kube/config
