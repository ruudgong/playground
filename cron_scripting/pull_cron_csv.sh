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
#echo "" > /data/servers/par/tyler/cron.csv

for host in `cat ip-list`; 
do
	ssh $host -o ConnectTimeout=3 -o StrictHostKeyChecking=no $'for user in $(cut -f1 -d: /etc/passwd); do echo \"$(hostname), $user,  $(sudo crontab -u $user -l | tr \'\\n\' \' | \')\"; done' >> cron.csv
	if [ $? -ne 0 ]; then
		echo $host >> failed_ssh.txt
	fi
done 


