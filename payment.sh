#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop-prj"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.devopslearn.shop
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

#### Python ####
dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing the Python3"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then   
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Create the roboshop username"
else
    echo -e "User already exist..$Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Create the Directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading the payment application code"

cd /app 
VALIDATE $? "Change to app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "Removing the existing code"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzip the code"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Install the requirements"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Copying the systemctl service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reload the Daemon"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "Enable the Payment server"

systemctl restart payment &>>$LOG_FILE
VALIDATE $? "reStart the Payment server"
