sudo apt update && sudo apt upgrade -y

curl -sfL https://get.k3s.io | sh -s - server --tls-san 18.188.213.27 --node-external-ip 18.188.213.27


sudo cp -i /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
export KUBECONFIG=~/.kube/config
kubectl get nodes
