# podman installation
echo "Configuring local repo, Please standby"
sleep 2

# configure the local repo
sudo mkdir -p /etc/containers/registries.conf.d
sudo cat << EOF | sudo tee /etc/containers/registries.conf.d/registry.conf
[[registry]]
location = "10.97.40.62:5000"
insecure = true
EOF

sudo containerd config default | sudo tee /etc/containerd/config.toml
# Below line is added due to a bug in SystemdCgroup - its redundant and will be removed in future release
sudo sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml

sudo mkdir -p /etc/containerd/certs.d/10.97.40.62:5000
sudo cat << EOF | sudo tee -a /etc/containerd/certs.d/10.97.40.62:5000/hosts.toml
server = "http://10.97.40.62:5000"
[host."http://10.97.40.62:5000"]
  capabilities = ["pull", "push", "resolve"]
  skip_verify = true
EOF

sudo sed -e "s,config_path = '/etc/containerd/certs.d:/etc/docker/certs.d',config_path = '/etc/containerd/certs.d',g" -i /etc/containerd/config.toml

# restart containerd
sudo systemctl daemon-reload
sudo systemctl restart containerd

export repo=10.97.40.62:5000
echo "export repo=10.97.40.62:5000" >> $HOME/.bashrc

sleep 4
echo ""


echo "Local Repo configured, follow the next steps"
