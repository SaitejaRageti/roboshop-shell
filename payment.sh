#!/bin/bash
START_TIME=$(date +%s)
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
    echo -e "$R you are running with Non root user. Run with root user $N" | tee -a $logfile
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
dnf install python3 gcc python3-devel -y
validate $? "installing python"

id roboshop
if [ $? -ne 0 ]
then
    echo " roboshop user is not created"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating the roboshop user"
else
    echo " user is already existing ; Skipping "
fi 

mkdir -p /app 
validate $? "creating the app directory"


curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$logfile
validate $? "dowlading the payment zip file in tmp directory"

rm -rf /app/*
cd /app 
unzip /tmp/payment.zip &>>$logfile
validate $? "unzipping the payment zip file" 

cd /app 
pip3 install -r requirements.txt
validate $? "installing requirements"


cp $script_dir/payment.service /etc/systemd/system/ 
validate $? "creating the payment service file"

systemctl daemon-reload &>>$logfile
validate $? "payment service file reload"

systemctl enable payment &>>$logfile
validate $? "payment enable"

systemctl start payment &>>$logfile
validate $? "payment service start"
