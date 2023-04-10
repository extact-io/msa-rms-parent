#!/bin/bash
SERVICE_NAME=$1
RUNNING_COUNT=`aws ecs describe-services --cluster rms-service-cluster --services $SERVICE_NAME --query 'services[0].runningCount'`
if [ $(echo $RUNNING_COUNT) != 0 ]; then # trim
  echo $SERVICE_NAME"is already running"
  exit 0
fi
aws ecs update-service --cluster rms-service-cluster --service $SERVICE_NAME --desired-count 1 > /dev/null
if [ $? -ne 0 ]; then
  echo $SERVICE_NAME"service start failed"
  exit 1
fi
