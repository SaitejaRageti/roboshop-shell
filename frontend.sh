#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logsfolder="/var/log/shellscripting-logs"
sciptname=$(echo $0 | cut -d "." -f1)
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


dnf module disable nginx -y &>>$logfile
validate $? "Nginx disable"

dnf module enable nginx:1.24 -y &>>$logfile
validate $? "nginx enable"

dnf install nginx -y &>>$logfile
validate $? "nginx installation"

systemctl enable nginx &>>$logfile
validate $? "systemctl nginx server enable is"

systemctl start nginx &>>$logfile
validate $? "systemctl nginx server start is"

rm -rf /usr/share/nginx/html/* &>>$logfile
validate $? "removing files inside html directory is "

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$logfile
validate $? "downloading frontend zip file"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$logfile
validate $? "unzipped"

cp $script_dir/nginx.conf /etc/nginx/nginx.conf &>>$logfile
validate $? "copy of nginx conf file is"

systemctl restart nginx &>>$logfile
validate $? "nginx restart is"







