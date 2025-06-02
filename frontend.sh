#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


if [$USERID -ne 0]
then
    echo "you are not running with root user"
else
    echo "You are running with root user go ahead"
    exit 1
fi

dnf module list ngnix

if [$? -ne 0]
then
    echo "ngnix is not installed, will install now"
    dnf install nginx -y
    if [$? -eq 0]
    then
        echo "nginx installed successfully"
    else
        echo " nginx installation failed "
else 
    echo "nginx is already installed"
fi
