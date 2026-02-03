#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5" #Image id
SG_ID="sg-0707ca13336ec1a61"    #Security group id
HOSTED_ZONE="Z03009212LOQ4VPB2FLS3" #hosted zone id
DOMAIN_NAME="devopslearn.shop"  #domain name

for instance in $@
do
    #Instance creation using Ami id, Sg id and will get instance id
    INSTANCE_ID=$( aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text )

#This script will create the instance and give you private ip
#aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro --security-group-ids sg-0707ca13336ec1a61 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Myinstance}]' --query 'Instances[0].PrivateIpAddress' --output text

    if [ $instance != "frontend" ]; then
    #Get PrivateIp Address
        IP=$( aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text )
        RECORD_NAME="$instance.$DOMAIN_NAME" #mongodb.devopslearn.shop
    else
        #Get PublicIp Address
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME" #devopslearn.shop
    fi

    echo "$instance: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE \
    --change-batch '
    {
        "Comment": "creating a simple A record for devopslearn.shop",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '
done