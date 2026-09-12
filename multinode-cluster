 #K3S KUBERNETES INSTALLATION WITH ONE WORKER NODE
 ================================================
 ================================================
 
 Master node installation
 =========================
 curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --tls-san 18.118.166.161 --node-external-ip 18.118.166.161" sh -

MASTERNODE TOKEN 
sudo cat /var/lib/rancher/k3s/server/node-token
K103ca7e7725d363736005e3de144ad72b7904e31b1f07df67b48224f26b230c51e::server:a02a7cb4851745c5ea5a442dc98e58c3

Worker node installation
=========================
curl -sfL https://get.k3s.io | K3S_URL=https://18.118.166.161:6443 K3S_TOKEN=K103ca7e7725d363736005e3de144ad72b7904e31b1f07df67b48224f26b230c51e::server:a02a7cb4851745c5ea5a442dc98e58c3 INSTALL_K3S_EXEC="agent --node-external-ip 16.59.142.64" sh -


kubeconfig file to connect to the cluser externally 
==================================================
cat /etc/rancher/k3s/k3s.yaml
