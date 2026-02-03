#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop-prj"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" #/var/log/shell-scripting/17-loops.sh

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privilage"
    exit 1 #failure is other than 0
fi 

VALIDATE(){ #functions receive the i/p's through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "Installing $2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "Installing $2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

##### Node JS ####
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabiling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Creating the system user"

mkdir /app 
VALIDATE $? "Creating the app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the Catalogue application"

cd /app 
VALIDATE $? "Change directory to app directory"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzip the catalogue"

npm install &>>$LOG_FILE
VALIDATE $? "Installing the npm for dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "Copy the systemctl service file"

systemctl daemon-reload 
VALIDATE $? "reload the daemon"

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enable the catalogue"

systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "start the catalogue"

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copy the Mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing Mongodb server"

mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "Load the catalogue products"

systemctl restart catalogue
VALIDATE $? "Restart the catalogue"
