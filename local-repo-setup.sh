#!/bin/bash

sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml

sudo mkdir -p /etc/containerd/certs.d/10.97.40.62:5000
sudo cat << EOF | sudo tee -a /etc/containerd/certs.d/10.97.40.62:5000/hosts.toml
server = "http://10.97.40.62:5000"
[host."http://10.97.40.62:5000"]
  capabilities = ["pull", "push", "resolve"]
  skip_verify = true
EOF

sudo sed -e "s,config_path = '/etc/containerd/certs.d:/etc/docker/certs.d',config_path = '/etc/containerd/certs.d',g" -i /etc/containerd/config.toml
