#!/bin/bash - 
#===============================================================================
#
#          FILE: ping_hosts.sh
# 
#         USAGE: ./ping_hosts.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: apache as apache (), 
#  ORGANIZATION: 
#       CREATED: 01/25/2021 15:44
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

echo "" > backend_interface_hosts.txt
echo "" > frontend_interface_hosts.txt
echo "" > unreachable_hosts.txt

cat unknown_cron_processes.txt.original | while read host
do
	nc -z $host-be1 22 > /dev/null
	if [ $? -eq 0 ]; then 
		echo "$host is backend"
		echo "$host-be1" >> backend_interface_hosts.txt
	else 
		nc -z $host 22 > /dev/null
		if [ $? -eq 0 ]; then 
			echo "$host is frontend"
			echo "$host" >> frontend_interface_hosts.txt
		else
			echo "$host is unreachable"
			echo "$host" >> unreachable_hosts.txt
		fi
	fi
done
