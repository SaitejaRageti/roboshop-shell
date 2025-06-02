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

cp $script_dir/mongo.repo /etc/yum.repos.d/ &>>$logfile
validate $? "mongo repo file creating"

dnf install mongodb-org -y &>>$logfile
validate $? "installing mongodb is"

systemctl enable mongod &>>$logfile
systemctl start mongod  &>>$logfile
validate $? "starting mongodb service"

sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf &>>$logfile
validate $? "replacing the ip to open internet"


systemctl restart mongod &>>$logfile
validate $? "restarting mongodb"