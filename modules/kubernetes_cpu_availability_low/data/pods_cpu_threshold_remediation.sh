

#!/bin/bash



# Set the namespace where the pods are running

NAMESPACE=${NAMESPACE}



# Get the name of the deployment or replicaset

DEPLOYMENT=${DEPLOYMENT}



# Get the threshold for CPU usage

THRESHOLD=${THRESHOLD}



# Get the list of pods running in the deployment or replicaset

PODS=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')



# Loop through each pod and check CPU usage

for POD in $PODS

do

  # Get the current CPU usage for the pod

  CPU=$(kubectl top pod $POD -n $NAMESPACE --containers | awk '/^'$POD'/ {print $2}')

  

  # Check if the CPU usage is below the threshold

  if (( $(echo "$CPU < $THRESHOLD" | bc -l) ))

  then

    # If the CPU usage is below the threshold, delete the pod

    kubectl delete pod $POD -n $NAMESPACE

    echo "Deleted pod $POD to free up resources."

  else

    echo "Skipping pod $POD as its CPU usage is above the threshold."

  fi

done



echo "Completed remediation of identifying and terminating idle or unused containers."