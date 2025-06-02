#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logsfolder="/var/logs/shellscripting-logs"
sciptname=$(echo "$0" | cut -d "." -f1)
logfile="$Logsfolder/$scriptname.log"
script_dir=$PWD


mkdir -p $Logsfolder

echo " script started executing at : $(date) "



if [ $USERID -ne 0 ]
then
    echo "you are running with Non root user. Run with root user"
    exit 1
else
    echo "You are running with root user go ahead"
fi

validate(){
    if [ $1 -eq 0 ]
    then 
        echo "$2 .......success"
    else
        echo "$2  ......failed"
        exit 1
    fi
}

dnf list installed nginx
if [ $? -eq 0 ]
then
    echo " nginx already installed"
    exit 1
else
    echo " start installing nginx"
fi

dnf module disable nginx -y
validate $? "Nginx disable"

dnf module enable nginx:1.24 -y
validate $? "nginx enable"

dnf install nginx -y
validate $? "nginx installation"

systemctl enable nginx
validate $? "systemctl nginx server enable is"

systemctl start nginx
validate $? "systemctl nginx server start is"

rm -rf /usr/share/nginx/html/* 
validate $? "removing files inside html directory is "

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
validate $? "downloading frontend zip file"

cd /usr/share/nginx/html
unzip /tmp/frontend.zipunzip /tmp/frontend.zip
validate $? "unzipped"

cp $script_dir/nginx.conf /etc/nginx/nginx.conf
validate $? "copy of nginx conf file is"

systemctl restart nginx 
validate $? "nginx restart is"







