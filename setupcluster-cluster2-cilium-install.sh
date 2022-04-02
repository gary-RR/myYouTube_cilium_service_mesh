#!/bin/bash

CLUSTER1="cluster1-cntx"
CLUSTER2="cluster2-cntx"


####### This section must be run only on the Master node#########################################################################################

#Initialize the cluster
sudo kubeadm init 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
#*******************************************************************************************************************************************************

#************************************************************Join other nodes***************************************************************************

#ssh in to each node that you want to include in the cluster and run "sudo kubeadm join ...." and the token you got in the previous step. 
    
#**************************************************************


#******************************************************************Install Cilium*************************************************
#Downlad cilium CLI
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz{,.sha256sum}

cilium install   --cluster-id=2 --cluster-name="cluster2"  --kube-proxy-replacement="strict"  --inherit-ca $CLUSTER1
    #cilium uninstall

#****************************************************************Verify Cluster Installation and install "Hubble"******************************************
#Veriy thal all PODS and nodes are ready. You may need to reboot if things are not healthy after a few minutes.
kubectl -n kube-system get pods -l k8s-app=cilium -o wide
kubectl get pods -n kube-system -o wide
kubectl get nodes -o wide

cilium status --wait


#***************************************************Setup Hubble******************************************************************
#Enabling Hubble requires the TCP port 4245 to be open on all nodes running Cilium. This is required for Relay to operate correctly.
cilium hubble enable

cilium status

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




























#**************************************************ad-hoc commands and notes****************************

#Get POD logs
kubectl logs hello-minikube-64b64df8c9-ln67f

#Untaint maste
kubectl taint node kube-master node-role.kubernetes.io/master-

#Add curl to POD
apk --no-cache add curl

#From inside cluster we can do
curl http://hello-world:8080
    #rather than ClusterIP
        curl http://10.99.252.65:8080


kubeadm token create --print-join-command #This will get teh token for adding a new node.
sudo kubeadm reset   #this will un-configure the kubernetes cluster.
#Deleting a worker node:
    kubectl cordon c1-kube-node1-cilium
    kubectl drain --ignore-daemonsets --force c1-kube-node1-cilium --delete-emptydir-data 
    kubectl delete node c1-kube-node1-cilium

    kubectl cordon c2-kube-node1-cilium
    kubectl drain --ignore-daemonsets --force c2-kube-node1-cilium --delete-emptydir-data 
    kubectl delete node c2-kube-node1-cilium

    sudo rm -r /etc/cni/net.d ;      sudo rm $HOME/.kube/config


--type=NodePort
--type=ClusterIP

#How to install docker enterprise on Win 2019: https://computingforgeeks.com/how-to-run-docker-containers-on-windows-server-2019/

#Get OS and version
cat /etc/os-release
	#Notes:
	cat /proc/version is showing kernel version. As containers run on the same kernel as the host. It is the same kernel as the host.
	cat /etc/*-release is showing the distribution release. It is the OS version, minus the kernel.
	A container is not virtualisation, in is an isolation system that runs directly on the Linux kernel. 
        It uses the kernel name-spaces, and cgroups. Name-spaces allow separate networks, process ids, mount points, users, hostname, 
        Inter-process-communication. cgroups allows limiting resources.

#How to install ip utility on Ubuntu:
    # apt update
    # apt install iproute2 -y

    #Kube context switching
    kubectl config use-context kubernetes-admin@kubernetes

#Copy cluster certs to Windows machines
scp -r $HOME/.kube gary@192.168.0.10:/Users/grost

#**************************************Postgres**********************************************************************
docker run --name postgres -e POSTGRES_PASSWORD=ostad1 -d postgres
docker exec -it postgres psql -U postgres
    postgres=# create database test
    docker exec -it postgres createdb -h localhost -p 5432 -U postgres products

#****************************************scp from remote server*****************************************************
scp gary@10.0.0.155:/home/gary/tests/*.* /Users/grost/OneDrive/YouTube-Channel/Video-15-Kube-Security/Scripts
#*******************************************************************************************************************