#!/bin/bash

# Update the package index
sudo dnf update -y

# Install required packages
sudo dnf install -y yum-utils device-mapper-persistent-data lvm2

# Install Docker
echo "Installing Docker..."
sudo dnf config-manager --add-repo=https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to the docker group
sudo usermod -aG docker $USER
newgrp docker

# Install Kind
echo "Installing Kind..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install kubectl
echo "Installing kubectl..."
# This overwrites any existing configuration in /etc/yum.repos.d/kubernetes.repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF
sudo yum install -y kubectl

# Install kubelet and kubeadm
echo "Installing kubelet and kubeadm..."
sudo dnf install -y kubelet kubeadm
sudo systemctl enable --now kubelet

# Install Helm
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Print versions
echo "Installation complete!"
echo "Docker version:"
docker --version
echo "Kind version:"
kind --version
echo "kubectl version:"
kubectl version --client
echo "Helm version:"
helm version
echo "kubelet version:"
kubelet --version
echo "kubeadm version:"
kubeadm version
