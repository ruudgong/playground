#!/bin/sh
##
## 
##
## Made by Smart Nwachukwu
## 
## This script can only be executed with a root priviledge
## 
## 
##

ps faux | grep /usr/sbin/winbindd | grep -v grep | awk '{print $2}' | xargs kill -9
/etc/init.d/winbind start

