#!/bin/bash

APP_NAME=$1
echo "App Name: $APP_NAME"


# define slot names
SLOT_BLUE="blue"
SLOT_GREEN="green"

# Initial Version
APP_VERSION=0
 

# check version of deployment in slot
function check_slot_version() {
    #echo "Checking version of $1 Slot"
    VERSION=$(kubectl get deployment -n $1 $APP_NAME -o jsonpath='{.metadata.labels.release}')
    #echo "Version: $VERSION"
    APP_VERSION=$VERSION
}

check_slot_version $SLOT_BLUE
BLUE_VERSION=$(echo $APP_VERSION | tr -d '.')

check_slot_version $SLOT_GREEN
GREEN_VERSION=$(echo $APP_VERSION | tr -d '.')

echo "Blue Version: $BLUE_VERSION"
echo "Green Version: $GREEN_VERSION"


 echo $GREEN_VERSION | tr -d '.'
 
if [ $GREEN_VERSION -gt $BLUE_VERSION  ]; then 
    echo "Green is higher than blue - swapping to green"
    kubectl apply -f ingress.yaml -n $SLOT_GREEN
    kubectl apply -f ingress-blue.yaml -n $SLOT_BLUE
    
else
    echo "Blue is higher than green - swapping to blue"
    kubectl apply -f ingress.yaml -n $SLOT_BLUE
    kubectl apply -f ingress-blue.yaml -n $SLOT_GREEN
fi



# para o swap, criar um script que inverta as urls do ingress entre os namespaces