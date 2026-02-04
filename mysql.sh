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

dnf install mysql-server -y &>>LOG_FILE
VALIDATE $? "Installing MYSQL"

systemctl enable mysqld &>>LOG_FILE
VALIDATE $? "Enabling the MYSQL"

systemctl start mysqld &>>LOG_FILE
VALIDATE $? "Start the MYSQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>>LOG_FILE
VALIDATE $? "Setting up Root Passwprd"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"


