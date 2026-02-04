#!/bin/bash

set -euo pipefail

trap 'echo "There is an error in $LINENO, Command is: $BASH_COMMAND"' ERR

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop-prj"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
MONGODB_HOST=mongodb.devopslearn.shop
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" #/var/log/shell-scripting/17-loops.sh

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privilage"
    exit 1 #failure is other than 0
fi 



##### Node JS ####
dnf module disable nodejs -y &>>$LOG_FILE
dnf module enable nodejs:20 -y &>>$LOG_FILE
dnf install nodejs -y &>>$LOG_FILE

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else 
    echo -e "User already exist..$Y SKIPPING $N"
fi

mkdir -p /app
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
cd /app 
rm -rf /app/*
unzip /tmp/catalogue.zip &>>$LOG_FILE
npm install &>>$LOG_FILE

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload 
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue &>>$LOG_FILE

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongoshshdg -y &>>$LOG_FILE

INDEX=$(mongosh --host mongodb.devopslearn.shop --quiet --eval "db.getMongo().getDBName().indexOf('catalogue')")
if [ $INDEX -1e 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
else
    echo -e "Products are already loaded...$Y SKIPPING $N"
fi

systemctl restart catalogue
