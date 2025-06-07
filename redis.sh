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

dnf module disable redis -y
validate $? "redis module disable is "

dnf module enable redis:7 -y
validate $? "redis module enable is "

dnf install redis -y 
validate $? "redis installation is "

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e 's/protected-mode yes/protected-mode no' /etc/redis/redis.conf &&
validate $? "making changes in redisconf to accept the remote connections"

systemctl enable redis
validate $? "enabling redis service"

systemctl start redis 
validate $? "starting the redis servicd"