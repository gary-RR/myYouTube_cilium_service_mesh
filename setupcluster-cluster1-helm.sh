#!/bin/bash

####### This section must be run only on the Master node#########################################################################################

#Initialize the cluster
sudo kubeadm init 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#*******************************************************************************************************************************************************

#************************************************************Join other nodes***************************************************************************

#ssh in to each node that you want to include in teh cluster and run "sudo kubeadm join ...." and the token you got in the previous step. 
    
#**************************************************************


#*********************************************************Install Cilium********************************************************************
#Install cilium
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz{,.sha256sum}

#Setup Helm repository
helm repo add cilium https://helm.cilium.io/
    #helm uninstall cilium -n kube-system #To uninstall cilium

#Make sure there are no spaces after "\" on each line!
#This topped working
helm install cilium cilium/cilium --version 1.11.2 \
  --namespace kube-system \
  --set cluster.name=cluster1 \
  --set cluster.id=1 \
  --set ipam.operator.clusterPoolIPv4PodCIDR="172.0.0.0/16" 


#****************************************************************Verify Cluster Installation and install "Hubble"******************************************
#Veriy thal all PODS and nodes are ready. You may need to reboot if things are not healthy after a few minutes.
kubectl -n kube-system get pods -l k8s-app=cilium -o wide
kubectl get pods -n kube-system -o wide
kubectl get nodes -o wide

#Validate that Cilium installation
cilium status --wait

#***If cilium and cluster is healty, enable "Hubble"
#Enable hubble. Make sure there are no spaces after "\"
helm upgrade cilium cilium/cilium --version 1.11.2 \
   --namespace kube-system \
   --reuse-values \
   --set hubble.relay.enabled=true \
   --set hubble.enabled=true 
   
kubectl get secret -n kube-system -o wide | grep cilium-ca

cilium hubble enable --create-ca 

kubectl get secret -n kube-system -o wide | grep cilium-ca

#In order to access the observability data collected by Hubble, install the Hubble CL
export HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
curl -L --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-amd64.tar.gz /usr/local/bin
rm hubble-linux-amd64.tar.gz{,.sha256sum}

#In order to access the Hubble API, create a port forward to the Hubble service from your local machine
cilium hubble port-forward&

hubble status 

hubble observe


