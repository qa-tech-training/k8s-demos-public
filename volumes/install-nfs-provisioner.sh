#!/bin/bash
helm repo add nfs-provisioner \
	https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm install nfs-provisioner nfs-provisioner/nfs-subdir-external-provisioner \
	--set nfs.server=k8scp,nfs.path=/opt/sfw,storageClass.volumeBindingMode=WaitForFirstConsumer
