#!/bin/bash
# Purpose: Detecting Hardware Errors
# Author: Chidai mollar 
# Note : The script must run as a cron-job.
# Last updated on : 28-may-2015
# modified by smart 
# -----------------------------------------------


# Store path to commands
LOGGER=/usr/bin/logger
FILE=/var/log/mcelog


# Store email settings
AEMAIL="your-email@your-domain.com"
ASUB="H/W Error - $(hostname)"
AMESS="Warning - Hardware errors found on $(hostname) @ $(date). See
log file for the details /var/log/mcelog."
OK_MESS="OK: NO Hardware Error Found."
WARN_MESS="ERROR: Hardware Error Found."


# Check if $FILE exists or not
if test ! -f "$FILE"
then
 echo "Error - $FILE not found or mcelog is not configured for 64
bit Linux systems."
 exit 1
fi


# okay search for errors in file
error_log=$(grep -c -i "hardware error" $FILE)


# error found or not?
if [ $error_log -gt 0 ]
then # yes error(s) found, let send an email
 echo "$AMESS" | email -s "$ASUB" $AEMAIL
else # naa, everything looks okay
 echo "$OK_MESS"
fi
