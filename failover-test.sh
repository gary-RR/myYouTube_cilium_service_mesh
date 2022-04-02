###################################################Test fail over #############################################
#Run the following two commands from two different terminals:

#From terminal1 run:
for i in $(seq 1 10000); 
do  kubectl exec -ti deployment/x-wing -- curl rebel-base 
done

#From terminal 2 run:
kubectl scale deployment rebel-base --replicas=0 --context $CLUSTER2


