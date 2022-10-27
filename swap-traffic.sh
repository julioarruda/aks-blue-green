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
    NAMESPACE_ENV=$(kubectl get namespace $1 -o jsonpath='{.metadata.labels.environment}')
    #echo "Version: $VERSION"
    NAMESPACE_ENVIRONMENT=$NAMESPACE_ENV
}

function check_service_ip() {
    SERVICE_IP=$(kubectl get service $APP_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}' -n $1)
}

check_slot_version $SLOT_BLUE
BLUE_ENVIRONMENT=$NAMESPACE_ENVIRONMENT

check_slot_version $SLOT_GREEN
GREEN_ENVIRONMENT=$NAMESPACE_ENVIRONMENT

check_service_ip $SLOT_BLUE
BLUE_IP=$SERVICE_IP

check_service_ip $SLOT_GREEN
GREEN_IP=$SERVICE_IP



echo "Blue Environment: $BLUE_ENVIRONMENT"
echo "Blue IP: $BLUE_IP"
echo "Green Environment: $GREEN_ENVIRONMENT"
echo "Green IP: $GREEN_IP"


 
if [[ $GREEN_ENVIRONMENT == "staging" ]]; then  
    echo "Green is staging - swapping to prod"
    kubectl label --overwrite namespace $SLOT_GREEN environment=prod
    az network traffic-manager endpoint update --name $SLOT_GREEN -g poc-traffic --profile-name poc-b3-traffic2 --type externalEndpoints --target $GREEN_IP --weight 1000 
    
    kubectl label --overwrite namespace $SLOT_BLUE environment=staging
    az network traffic-manager endpoint update --name $SLOT_BLUE -g poc-traffic --profile-name poc-b3-traffic2 --type externalEndpoints --target $BLUE_IP --weight 1 
    
elif [[ $BLUE_ENVIRONMENT == "staging" ]]; then
    echo "Blue is staging - swapping to prod"
    kubectl label --overwrite namespace $SLOT_BLUE environment=prod
    az network traffic-manager endpoint update --name $SLOT_BLUE -g poc-traffic --profile-name poc-b3-traffic2 --type externalEndpoints --target $BLUE_IP --weight 1000

    kubectl label --overwrite namespace $SLOT_GREEN environment=staging
    az network traffic-manager endpoint update --name $SLOT_GREEN -g poc-traffic --profile-name poc-b3-traffic2 --type externalEndpoints --target $GREEN_IP --weight 1
fi

