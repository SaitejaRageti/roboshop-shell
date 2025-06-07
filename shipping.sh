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
dnf install maven -y
validate $? "installing maven"

id roboshop
if [ $? -ne 0 ]
then
    echo " roboshop user is not created"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating the roboshop user"
else
    echo " user is already existing ; Skipping "
fi 

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

mkdir -p /app 
validate $? "creating the app directory"


curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$logfile
validate $? "dowlading the shipping zip file in tmp directory"

rm -rf /app/*
cd /app 
unzip /tmp/shipping.zip &>>$logfile
validate $? "unzipping the shipping zip file" 

cd /app 
mvn clean package
validate $? "cleaning the maeven packages"
mv target/shipping-1.0.jar shipping.jar 
validate $? "moving shipping jar from tmp to app directory"

cp $script_dir/shipping.service /etc/systemd/system/ 
validate $? "creating the shipping service file"

systemctl daemon-reload &>>$logfile
validate $? "shipping service file reload"

systemctl enable shipping &>>$logfile
validate $? "shipping enable"

systemctl start shipping &>>$logfile
validate $? "shipping service start"

dnf install mysql -y 
validate $? "installing mysql"

mysql -h mysql.rageti.site -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &
if [ $? -ne 0 ]
then
mysql -h mysql.rageti.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql
mysql -h mysql.rageti.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql 
mysql -h mysql.rageti.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql
validate $? "loading the data"
else
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
fi

systemctl restart shipping

END_TIME=$(date +%s)
TOTALTIME=$(($END_TIME - $START_TIME))

echo -e "total time taken for ececuting this scrip is $TOTALTIME"
 