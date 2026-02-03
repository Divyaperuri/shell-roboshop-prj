#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop-prj"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
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

dnf module disable nodejs -y &>>LOG_FILE
VALIDATE $? "Disabling the nodejs"

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "Enabling the nodejs"

dnf install nodejs -y &>>LOG_FILE
VALIDATE $? "Installing the nodejs"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Create the roboshop username"
else
    echo -e "User already exist..$Y SKIPPING $N"
fi

mkdir /app 
VALIDATE $? "Create a Directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>LOG_FILE
VALIDATE $? "Download the user application"

cd /app 
VALIDATE $? "Change the directory"

rm -rf /app/*
VALIDATE $? "Removing the existing code"

unzip /tmp/user.zip &>>LOG_FILE
VALIDATE $? "Unzip the code"

npm install &>>LOG_FILE
VALIDATE $? "Installing the dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>LOG_FILE
VALIDATE $? "Copy the service file"

systemctl daemon-reload &>>LOG_FILE
VALIDATE $? "Reload the daemon"

systemctl enable user &>>LOG_FILE
VALIDATE $? "Enabling the User"

systemctl start user &>>LOG_FILE
VALIDATE $? "Start the User"

