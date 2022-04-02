
CLUSTER1="cluster1-cntx"
CLUSTER2="cluster2-cntx"


cilium status --context $CLUSTER1
cilium status --context $CLUSTER2

#ENable service mesh on both clusters 
cilium clustermesh enable --context $CLUSTER1 --service-type LoadBalancer #NodePort
    cilium clustermesh disable --context $CLUSTER1
cilium clustermesh enable --context $CLUSTER2 --service-type LoadBalancer #NodePort
     cilium clustermesh disable --context $CLUSTER2

#Check teh status
cilium clustermesh status --context $CLUSTER1 --wait
cilium clustermesh status --context $CLUSTER2 --wait

#Establish the mesh between clusters
cilium clustermesh connect --context $CLUSTER1 --destination-context $CLUSTER2
    cilium clustermesh disconnect --context $CLUSTER1 --destination-context $CLUSTER2

#Check the service mesh status 
cilium clustermesh status --context $CLUSTER1 --wait
cilium clustermesh status --context $CLUSTER2 --wait

#Deploy the test app to both clusters
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/1.11.2/examples/kubernetes/clustermesh/global-service-example/cluster1.yaml --context $CLUSTER1
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/1.11.2/examples/kubernetes/clustermesh/global-service-example/cluster2.yaml --context $CLUSTER2

#Call the service
kubectl exec -ti deployment/x-wing -- curl rebel-base 

###################################################Test fail over #############################################
#Run the following two commands from two different terminals:

for i in $(seq 1 10000); 
do  kubectl exec -ti deployment/x-wing -- curl rebel-base 
done

kubectl scale deployment rebel-base --replicas=0 --context $CLUSTER2
##############################################################################

kubectl exec -ti deployment/x-wing -- curl rebel-base.default.svc.cluster.local
kubectl exec -ti deployment/hello-world -- wget  hello-world.default.svc.cluster.local:8080 
#Deploy network policy


#Cleanup
kubectl delete -f https://raw.githubusercontent.com/cilium/cilium/1.11.2/examples/kubernetes/clustermesh/global-service-example/cluster1.yaml --context $CLUSTER1
kubectl delete -f https://raw.githubusercontent.com/cilium/cilium/1.11.2/examples/kubernetes/clustermesh/global-service-example/cluster2.yaml --context $CLUSTER2
































scp config gary@192.168.0.14:/home/gary/.kube

kubectl get nodes -o wide --context $CLUSTER1
kubectl get nodes -o wide --context $CLUSTER2

#Install Cilium CLI
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz{,.sha256sum}

# cilium hubble port-forward&
# hubble observe --from-port 80
# hubble observe --pod deathstar --protocol http
# hubble observe --pod deathstar --verdict DROPPED
