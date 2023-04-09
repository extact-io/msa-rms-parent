#!/bin/bash -x

INSTANCE_ID=i-0a3ef21c1550daf62
STATUS=`aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --query 'InstanceStatuses[0].InstanceState.Name'`
if [ $STATUS = '"running"' ]; then
  echo "already running"
  exit 0
fi

aws ec2 start-instances --instance-ids $INSTANCE_ID
if [ $? -ne 0 ]; then
  echo "instance start failed"
  exit 1
fi

