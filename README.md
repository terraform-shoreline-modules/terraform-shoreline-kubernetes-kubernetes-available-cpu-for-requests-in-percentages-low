
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes CPU Availability Low
---

The "Kubernetes CPU Availability Low" incident type refers to an incident where the available CPU for requests in a Kubernetes cluster is too low. This can cause performance issues and potential downtime for the affected service. This incident may be triggered by a monitoring system or an alert from Kubernetes itself. It is important to investigate and resolve this incident promptly to ensure the service is operating optimally.

### Parameters
```shell
# Environment Variables

export POD_NAME="PLACEHOLDER"

export CONTAINER_NAME="PLACEHOLDER"

export CLUSTER_NAME="PLACEHOLDER"

export NODE_INSTANCE_TYPE="PLACEHOLDER"

export NODE_COUNT="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export DEPLOYMENT="PLACEHOLDER"

export CPU_THRESHOLD="PLACEHOLDER"
```

## Debug

### Check the CPU usage of all the pods in the Kubernetes cluster
```shell
kubectl top pods --all-namespaces
```

### Check the CPU usage of all the nodes in the Kubernetes cluster
```shell
kubectl top nodes
```

### Check the CPU limits and requests of the pods in the Kubernetes cluster
```shell
kubectl describe pods --all-namespaces | grep -E 'Limits|Requests'
```

### Check the CPU usage of the containers in a specific pod
```shell
kubectl exec ${POD_NAME} -c ${CONTAINER_NAME} -- top -n 1 -b | grep -E 'CPU'
```

### Check the Kubernetes events to see if there are any relevant error messages
```shell
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Resource limits were not set properly in containers, leading to overconsumption of CPU resources.
```shell


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


```

### Inadequate resource allocation by the Kubernetes cluster, leading to insufficient CPU resources being available.
```shell


#!/bin/bash



# Define variables

NAMESPACE=${NAMESPACE}

DEPLOYMENT=${DEPLOYMENT}

CONTAINER=${CONTAINER}

CPU_THRESHOLD=${CPU_THRESHOLD}



# Get the CPU usage for the specified container in the specified deployment

CPU_USAGE=$(kubectl top pod -n $NAMESPACE -l app=$DEPLOYMENT | grep $CONTAINER | awk '{print $2}')



# Check if the CPU usage exceeds the threshold

if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then

  # If the CPU usage exceeds the threshold, print a warning and exit with status 1

  echo "Warning: CPU usage for $CONTAINER in $DEPLOYMENT is above the threshold of $CPU_THRESHOLD"

  exit 1

else

  # If the CPU usage is below the threshold, print a success message and exit with status 0

  echo "CPU usage for $CONTAINER in $DEPLOYMENT is below the threshold of $CPU_THRESHOLD"

  exit 0

fi


```

## Repair

### Increase the resources allocated to the Kubernetes cluster to avoid CPU contention.
```shell


#!/bin/bash



# Set variables

CLUSTER_NAME=${CLUSTER_NAME}

NODE_COUNT=${NODE_COUNT}

NODE_INSTANCE_TYPE=${NODE_INSTANCE_TYPE}



# Update node group

eksctl get nodegroup --cluster=$CLUSTER_NAME -o yaml > nodegroup.yaml

sed -i "s/instanceType:.*/instanceType: $NODE_INSTANCE_TYPE/" nodegroup.yaml

sed -i "s/minSize:.*/minSize: $NODE_COUNT/" nodegroup.yaml

sed -i "s/maxSize:.*/maxSize: $NODE_COUNT/" nodegroup.yaml

eksctl apply nodegroup -f nodegroup.yaml --approve



# Wait for nodes to be ready

while [ `kubectl get nodes | grep Ready | wc -l` -lt $NODE_COUNT ];

do

    sleep 5

done



echo "Node group updated successfully."


```

### Identify and terminate idle or unused containers to free up resources.
```shell


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


```