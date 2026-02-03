#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop-prj"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
MONGODB_HOST=redis.devopslearn.shop
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

dnf module disable nodejs -y
VALIDATE $? "Disabling the nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling the nodejs"

dnf install nodejs -y
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

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
VALIDATE $? "Download the cart application"

cd /app 
VALIDATE $? "Change the directory"

unzip /tmp/cart.zip
VALIDATE $? "Unzip the code"

npm install 
VALIDATE $? "Installing the dependencies"

cp $SCRIPR_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copy the service file"

systemctl daemon-reload
VALIDATE $? "Reload the daemon"

systemctl enable cart 
VALIDATE $? "Enabling the Cart"

systemctl start cart
VALIDATE $? "Start the Cart"
