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

 
# old form to check, based on version number 
# if [ $GREEN_VERSION -gt $BLUE_VERSION  ]; then 
#     echo "Green is higher than blue - deploying blue"
#     SLOT="blue"
# else
#     echo "Blue is higher than green - deploying green"
#     SLOT="green"
# fi

# new form to check, based on environment

if [[ $GREEN_ENVIRONMENT == "prod" && $BLUE_ENVIRONMENT == "staging" ]]; then 
    echo "Green is prod - deploying blue"
    SLOT="blue"
elif [[ $BLUE_ENVIRONMENT == "prod" && $GREEN_ENVIRONMENT == "staging" ]]; then
    echo "Blue is prod - deploying green"
    SLOT="green"
else
    echo "It's a new deployment, deploying blue"
    SLOT="blue"
fi


echo "Deploying to $SLOT"

# Deploy to slot

 kubectl apply -f deployment.yml -n $SLOT
 kubectl apply -f service.yml -n $SLOT
 kubectl apply -f ingress-blue.yml -n $SLOT