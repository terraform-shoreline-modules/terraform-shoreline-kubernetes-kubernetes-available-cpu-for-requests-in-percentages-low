

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