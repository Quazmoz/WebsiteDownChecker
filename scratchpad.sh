#!/bin/bash
#Get the node ready
#This is currently installed on the secondary
sudo apt install ssmtp

sudo nano /etc/ssmtp/ssmtp.conf

UseTLS=Yes
UseSTARTTLS=Yes
FromLineOverride=YES
root=redacted@gmail.com
mailhub=smtp.gmail.com:587
AuthUser=redacted@gmail.com
AuthPass=redacted
hostname=ubuntu-secondary

#https://linuxhint.com/bash_script_send_email/