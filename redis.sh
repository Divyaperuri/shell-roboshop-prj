#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop-prj"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" #/var/log/shell-scripting/17-loops.sh
START_TIME=$(date +%s)

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

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling the Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling the Redis 7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing the redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling the Redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Start the Redis"

