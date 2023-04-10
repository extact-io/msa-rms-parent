#!/bin/bash
SERVICE_NAME=$1
RUNNING_COUNT=`aws ecs describe-services --cluster rms-service-cluster --services $SERVICE_NAME --query 'services[0].runningCount'`
if [ $(echo $RUNNING_COUNT) = 0 ]; then # trim
  echo $SERVICE_NAME"is already stoped"
  exit 0
fi
aws ecs update-service --cluster rms-service-cluster --service $SERVICE_NAME --desired-count 0 > /dev/null
if [ $? -ne 0 ]; then
  echo $SERVICE_NAME"service stop failed"
  exit 1
fi
