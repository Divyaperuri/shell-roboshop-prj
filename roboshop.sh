#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0707ca13336ec1a61" #security group

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --count 1 --instance-type t3.micro --security-group-ids sg-0707ca13336ec1a61 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instance[0].InstanceId' --output text)

    #Get Private ip
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instance --instance-ids i-0d3ddd2e9f1f2aebd --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        IP=$(aws ec2 describe-instance --instance-ids i-0d3ddd2e9f1f2aebd --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi

    echo "$instance: $IP"
done