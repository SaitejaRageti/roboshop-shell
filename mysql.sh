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

dnf install mysql-server -y
validate $? "installation of mysql server"

systemctl enable mysqld
validate $? "enabling the mysql"

systemctl start mysqld
validate $? "starting mysql"  

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "changing root pass"

END_TIME=$(date +%s)

timeTakenforexecution=$(($END_TIME - $START_TIME))

echo -e " $G Total time taken for executing this script is $timeTakenForexecution $N "
