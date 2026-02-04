#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop-prj"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
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
 ### Maven ###
dnf install maven -y &>>LOG_FILE
VALIDATE $? "Installing Maven"

id roboshop &>>LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>LOG_FILE
    VALIDATE $? "Create the roboshop username"
else
    echo -e "User already exist..$Y SKIPPING $N"
fi

mkdir -p /app &>>LOG_FILE
VALIDATE $? "Create a Directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>/LOG_FILE
VALIDATE $? "Download the shipping application code"

cd /app 
VALIDATE $? "Changing the Directory"

rm -rf /app/*
VALIDATE $? "Removing the existing code"

unzip /tmp/shipping.zip &>>LOG_FILE
VALIDATE $? "Unzip the code"

cd /app
VALIDATE $? "Changing the Directory"

mvn clean package &>>LOG_FILE
VALIDATE $? "Clean the package"

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "Move the file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service 
VALIDATE $? "Copy the Service file"

systemctl daemon-reload &>>LOG_FILE
VALIDATE $? "Reload the Daemon"

systemctl enable shipping &>>LOG_FILE 
VALIDATE $? "Enabling the Shipping"

systemctl start shipping &>>LOG_FILE
VALIDATE $? "Start the Shipping"

dnf install mysql -y &>>LOG_FILE
VALIDATE $? "Install MYSQL"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'  &>>LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql  &>>LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>LOG_FILE 
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql  &>>LOG_FILE
else
    echo -e "Shipping data is already loaded... $Y SKIPPING $N"
fi

systemctl restart shipping  &>>LOG_FILE
VALIDATE $? "Restart the Shipping"

