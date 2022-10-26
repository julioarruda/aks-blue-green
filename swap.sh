#!/bin/bash

APP_NAME=$1
echo "App Name: $APP_NAME"

APP_VERSION=$2
echo "App Version: $APP_VERSION"

# define slot names
SLOT_BLUE="blue"
SLOT_GREEN="green"

# Initial Version
APP_VERSION=0
NAMESPACE_ENVIRONMENT="staging"
 

# check version of deployment in slot
function check_slot_version() {
    #echo "Checking version of $1 Slot"
    VERSION=$(kubectl get deployment -n $1 $APP_NAME -o jsonpath='{.metadata.labels.release}')
    NAMESPACE_ENV=$(kubectl get namespace $1 -o jsonpath='{.metadata.labels.environment}')
    #echo "Version: $VERSION"
    APP_VERSION=$VERSION
    NAMESPACE_ENVIRONMENT=$NAMESPACE_ENV
}

check_slot_version $SLOT_BLUE
BLUE_VERSION=$(echo $APP_VERSION | tr -d '.')
BLUE_ENVIRONMENT=$NAMESPACE_ENVIRONMENT

check_slot_version $SLOT_GREEN
GREEN_VERSION=$(echo $APP_VERSION | tr -d '.')
GREEN_ENVIRONMENT=$NAMESPACE_ENVIRONMENT

echo "Blue Version: $BLUE_VERSION"
echo "Green Version: $GREEN_VERSION"
echo "Blue Environment: $BLUE_ENVIRONMENT"
echo "Green Environment: $GREEN_ENVIRONMENT"


 
if [[ $GREEN_ENVIRONMENT == "staging" ]]; then  
    echo "Green is staging - swapping to prod"
    kubectl apply -f ingress.yml -n $SLOT_GREEN
    kubectl label --overwrite namespace $SLOT_GREEN environment=prod 
    
    kubectl apply -f ingress-blue.yml -n $SLOT_BLUE
    kubectl label --overwrite namespace $SLOT_BLUE environment=staging 
    
elif [[ $BLUE_ENVIRONMENT == "staging" ]]; then
    echo "Blue is staging - swapping to prod"
    kubectl apply -f ingress.yml -n $SLOT_BLUE
    kubectl label --overwrite namespace $SLOT_BLUE environment=prod

    kubectl apply -f ingress-blue.yml -n $SLOT_GREEN
    kubectl label --overwrite namespace $SLOT_GREEN environment=staging
fi



# para o swap, criar um script que inverta as urls do ingress entre os namespaces