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

dnf module disable nginx -y
VALIDATE $? "Disabling the nginx"

dnf module enable nginx:1.24 -y
VALIDATE $? "Enabling the nginx"

dnf install nginx -y
VALIDATE $? "Installing the Nginx"

systemctl enable nginx 
VALIDATE $? "Enable the Nginx"

systemctl start nginx 
VALIDATE $? "Start the Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove the nginx page content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Download the code"

cd /usr/share/nginx/html 
VALIDATE $? "Change the directory"

unzip /tmp/frontend.zip
VALIDATE $? "Unzip the file"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copy the config file"

systemctl restart nginx 
VALIDATE $? "Restart the nginx"