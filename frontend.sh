#!/bin/bash

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

VALIDATE(){ #functions receive the i/p's through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "Installing $2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "Installing $2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nginx -y &>>LOG_FILE
VALIDATE $? "Disabling the nginx"

dnf module enable nginx:1.24 -y &>>LOG_FILE
VALIDATE $? "Enabling the nginx"

dnf install nginx -y &>>LOG_FILE
VALIDATE $? "Installing the Nginx"

systemctl enable nginx  &>>LOG_FILE
VALIDATE $? "Enable the Nginx"

systemctl start nginx &>>LOG_FILE
VALIDATE $? "Start the Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove the nginx page content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>LOG_FILE
VALIDATE $? "Download the code"

cd /usr/share/nginx/html 
VALIDATE $? "Change the directory"

unzip /tmp/frontend.zip &>>LOG_FILE
VALIDATE $? "Unzip the file"

rm -rf /etc/nginx/nginx.conf &>>LOG_FILE
VALIDATE $? "Removing the nginx conf file"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>LOG_FILE
VALIDATE $? "Copy the nginx config file"

systemctl restart nginx &>>LOG_FILE
VALIDATE $? "Restart the nginx"