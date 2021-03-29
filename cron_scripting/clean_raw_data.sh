#!/bin/bash - 
#===============================================================================
#
#          FILE: clean_raw_data.sh
# 
#         USAGE: ./clean_raw_data.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: apache as apache (), 
#  ORGANIZATION: 
#       CREATED: 01/26/2021 13:02
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

full_host_file="clean_data/ash_full_hosts.txt"
unreachable_file="clean_data/unreachable.txt"

echo "" > $full_host_file
echo "" > $unreachable_file

raw_host_list=( "raw/frontend_interface_hosts.txt" "raw/backend_interface_hosts.txt" "raw/unreachable_hosts.txt" )
#decommission_list="raw/decommission_list.txt"

#cat $decommission_list | cut -d ':' -f 2 > clean_data/decommission_list.txt

for file in $raw_host_list
do
	for host in $(cat $file)
	#for host in $(cat $file | cut -d ' ' -f 1)
	do
		if  ! grep -Fxq "$host" clean_data/decommission_list.txt; then
			timeout 5 ssh $host -o ConnectTimeout=3 -o StrictHostKeyChecking=no 'echo "hello world"' &> /dev/null
			if [ $? -eq 0 ]; then 
				echo $host >> $full_host_file
			else
				timeout 5 ssh $host-be1 -o ConnectTimeout=3 -o StrictHostKeyChecking=no 'echo "hello world"' &> /dev/null
				if [ $? -eq 0 ]; then 
					echo "$host-be1" >> $full_host_file
				else 
					echo "$host" >> $unreachable_file
				fi
			
			fi
		fi
	done
done
