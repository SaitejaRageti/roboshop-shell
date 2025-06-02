#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


if [ $USERID -ne 0 ]
then
    echo "you are running with Non root user. Run with root user"
    exit 1
else
    echo "You are running with root user go ahead"
fi

dnf module disable nginx -y

if [ $? -eq 0 ]
then 
    echo " disabled successfully"
else
    echo "disable failed"
    exit 1
fi

dnf module enable nginx:1.24 -y

if [ $? -eq 0 ]
then 
    echo " enabled successfully"
else
    echo "enable failed"
    exit 1
fi

dnf install nginx -y 

if [ $? -eq 0 ]
then 
    echo " installed successfully"
else
    echo "installation failed"
    exit 1
fi

