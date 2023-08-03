

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