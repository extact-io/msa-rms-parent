#!/bin/bash
GIT_ROOT=`git rev-parse --show-toplevel`
cd $GIT_ROOT/scripts
sh ./ec2_stop.sh
sh ./ecs_stop.sh item-service
sh ./ecs_stop.sh reservation-service
sh ./ecs_stop.sh user-service

