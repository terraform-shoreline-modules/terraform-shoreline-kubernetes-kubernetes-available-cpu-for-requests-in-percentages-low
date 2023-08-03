

#!/bin/bash



# Set the Kubernetes namespace and deployment name

NAMESPACE=${NAMESPACE}

DEPLOYMENT=${DEPLOYMENT}



# Get the pod name for the deployment

POD=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT -o jsonpath='{.items[0].metadata.name}')



# Get the CPU usage for the pod

CPU_USAGE=$(kubectl top pod $POD -n $NAMESPACE --containers | awk '{print $2}' | tail -n1)



# Get the CPU limit for the pod

CPU_LIMIT=$(kubectl get pod $POD -n $NAMESPACE -o jsonpath='{.spec.containers[0].resources.limits.cpu}')



# Get the CPU request for the pod

CPU_REQUEST=$(kubectl get pod $POD -n $NAMESPACE -o jsonpath='{.spec.containers[0].resources.requests.cpu}')



# Compare the CPU usage to the limit and request

if (( $(bc ${<< "$CPU_USAGE } $CPU_LIMIT") )); then

    echo "CPU usage for $POD is above the limit of $CPU_LIMIT"

elif (( $(bc ${<< "$CPU_USAGE } $CPU_REQUEST") )); then

    echo "CPU usage for $POD is above the request of $CPU_REQUEST"

else

    echo "CPU usage is within limits for $POD"

fi