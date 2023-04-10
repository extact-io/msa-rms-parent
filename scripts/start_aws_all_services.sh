#!/bin/bash
GIT_ROOT=`git rev-parse --show-toplevel`
cd $GIT_ROOT/scripts
sh ./ec2_start.sh
sh ./ecs_start.sh item-service
sh ./ecs_start.sh reservation-service
sh ./ecs_start.sh user-service

