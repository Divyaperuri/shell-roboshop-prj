#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5" #Image ID
SG_ID="sg-0707ca13336ec1a61" #security group
ZONE_ID="Z03009212LOQ4VPB2FLS3" #Hosted zone id
DOMAIN_NAME="devopslearn.shop"

for instance in $@ #mongodb redis mysql
do
    #Instance creation 
    INSTANCE_ID=$(aws ec2 run-instances \ 
    --image-id $AMI_ID \  
    --instance-type "t3.micro" \ 
    --security-group-ids $SG_ID \ 
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \ 
    --query 'Instances[0].InstanceId' \ 
    --output text)

    #Get Private ip
    if [ $instance != "frontend" ]; then
        IP=$( ws ec2 describe-instances \ 
            --instance-ids $INSTANCE_ID \ 
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \ 
            --output text)
            RECORD_NAME="$instance.$DOMAIN_NAME" #mongodb.devopslearn.shop : domain name for mongodb server
    else
        IP=$(aws ec2 describe-instances \ 
            --instance-ids $INSTANCE_ID \ 
            --query 'Reservations[0].Instances[0].PublicIpAddress' \ 
            --output text)
        RECORD_NAME="$DOMAIN_NAME" #devopslearn.shop : domain name for frontend server
    fi

    echo "$instance: $IP"

    aws route53 change-resource-record-sets \ 
    --hosted-zone-id $ZONE_ID \ 
    --change-batch '
    {
        "Comment": "Updating record set",
        "Changes": [
            {
            "Action"               : "UPSERT",
            "ResourceRecordSet"    : {
                "Name"                : "'$RECORD_NAME'",
                "Type"               : "A" ,
                "TTL"                : 1,
                "ResourceRecords"    : [
                {
                    "Value"           : "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '
    echo "record updated for $instance"

done