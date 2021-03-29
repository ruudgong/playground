#!/bin/bash - 
#===============================================================================
#
#          FILE: pull_cron.sh
# 
#         USAGE: ./pull_cron.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: apache as apache (), 
#  ORGANIZATION: 
#       CREATED: 01/25/2021 16:02
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

function timeout { 
    timeout="$1";
    grep -qP '^\d+$' <<< $timeout || timeout=10
    shift 
    cmd="$@"

    ( 
        eval "$cmd" &
        child=$!
        trap -- "" SIGTERM 
        (       
                sleep $timeout
                kill $child 2> /dev/null 
        ) &     
        wait $child
    )
}

echo "" > failed_ssh.txt

for host in `cat backend_interface_hosts.txt`; 
do
	timeout 5 ssh $host -o ConnectTimeout=3 -o StrictHostKeyChecking=no "hostname ; crontab -l > /data/servers/par/tyler/$host.cron"
	if [ $? -ne 0 ]; then
	echo $host >> failed_ssh.txt
	fi
done 

for host in `cat frontend_interface_hosts.txt`; 
do
	timeout 5 ssh $host -o ConnectTimeout=5 -o StrictHostKeyChecking=no "hostname ; crontab -l > /data/servers/par/tyler/$host.cron"
	if [ $? -ne 0 ]; then
	echo $host >> failed_ssh.txt
	fi
done 


