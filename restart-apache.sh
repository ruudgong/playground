#!/bin/bash
#===============================================================================
#
#          FILE: restart-apache.sh 
#
#         USAGE: ./restart-apache.sh
#
#   DESCRIPTION: This script will bounce apache if it's not running, this can be set 
#                as a cronjob or event handler in a monitoring tool like Nagios                 
#       OPTIONS:                             
#				                                                     
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#		 Author: ruudgong
#       UPDATED: 
#  ORGANIZATION: 
#       CREATED:  
#      REVISION: 
#
#
#===============================================================================

RESTART="/sbin/service httpd restart"
PGREP="/usr/bin/pgrep"
HTTPD="httpd"

$PGREP ${HTTPD}
if [ $? -ne 0 ] # if httpd isn't running

then

 $RESTART

fi
