#!/bin/bash
# HTTPD Process Monitor
# Bounce httpd Web Server When It breaks or goes down
# -------------------------------------------------------------------------
# This is just a simple shell script that can enable you restart apache web server when it breaks.
# To avoid a contastant manual trigger of this script, you wish to set a cron job for constant autamation
# As as personal choice, I prefer to set  a systemwide crojob instead of individual user cronjobs. This method
# gives your the flexibilty to  consolidate your cron at a particular location and not have them all over the place
# incase you need to troubleshoot system issues relating to cronjobs. 
#
#----------------------------------------------------------------------------------------------------
############# This for loop help to identify all the cronjob and the owner on your system ###########
# for user in $(cut -f1 -d: /etc/passwd); do echo $user; sudo crontab -u $user -l; done 
#
# Added by Smart Nwachukwu on 2016-06-13
# --------------------------------------------------------------------------------------------------

# RHEL and its derivatives restart command

RESTART="/sbin/service httpd restart"

PGREP="/usr/bin/pgrep"

HTTPD="httpd"

$PGREP ${HTTPD}
if [ $? -ne 0 ] # if httpd isn't running
then

 $RESTART
fi
