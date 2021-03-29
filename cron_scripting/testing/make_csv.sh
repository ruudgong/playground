#!/bin/bash - 
#===============================================================================
#
#          FILE: make_csv.sh
# 
#         USAGE: ./make_csv.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: apache as apache (), 
#  ORGANIZATION: 
#       CREATED: 01/26/2021 14:42
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


echo "" > result.txt

echo "host-one, $(cat "test.txt" | tr '\n' ' | ')" >> result.txt
echo "host-two, $(cat "test.txt" | tr '\n' ' | ')" >> result.txt
echo "host-three, $(cat "test.txt" | tr '\n' ' | ')" >> result.txt

