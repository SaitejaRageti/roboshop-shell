#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logsfolder="/var/log/shellscripting-logs"
scriptname=$(echo $0 | cut -d "." -f1)
logfile="$Logsfolder/$scriptname.log"
script_dir=$PWD

mkdir -p $Logsfolder

echo " script started executing at : $(date) "

if [ $USERID -ne 0 ]
then
    echo -e "$R you are running with Non root user. Run with root USER $N" | tee -a $logfile
    exit 1
else
    echo -e "$G You are running with root user go ahead $N" | tee -a $logfile
fi

validate(){
    if [ $1 -eq 0 ]
    then 
        echo -e "$2 .......$G success $N" | tee -a $logfile
    else
        echo "$2  ......$R failed $N" | tee -a $logfile
        exit 1
    fi
}

dnf module disable nodejs -y &>>$logfile
validate $? "modue disabele is"

dnf module enable nodejs:20 -y &>>$logfile
validate $? "module enable is"

dnf install nodejs -y &>>$logfile
validate $? "nodejs installation is"

id roboshop
if [ $? -ne 0 ]
then
    echo " roboshop user is not created"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system cart" roboshop
    validate $? "creating the roboshop user"
else
    echo " user is already existing ; Skipping "
fi 

mkdir -p /app 
validate $? "creating the app directory"


curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$logfile
validate $? "dowlading the cart zip file in tmp directory"

rm -rf /app/*
cd /app 
unzip /tmp/cart.zip &>>$logfile
validate $? "unzipping the cart zip file" 

cd /app 
npm install 
validate $? "npm installing dependencies"

cp $script_dir/cart.service /etc/systemd/system/ 
validate $? "creating the cart service file"

systemctl daemon-reload &>>$logfile
validate $? "cart service file reload"

systemctl enable cart &>>$logfile
validate $? "cart enable"

systemctl start cart &>>$logfile
validate $? "cart service start"









