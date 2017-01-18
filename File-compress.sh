[root@eq-prod-log1 scripts]# Zapper-compress.sh
#!/bin/bash
#===============================================================================
#
#          FILE: Zapper-compress.sh
#
#         USAGE: ./Zapper-compress.sh
#
#   DESCRIPTION: This is used to compress files in place it is meant to be an emergency measure and protect data integrerty.
#
#       OPTIONS: Need to name a file
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: 
#  ORGANIZATION: 
#       CREATED: 
#      REVISION: 
#===============================================================================

set -o nounset                           # Treat unset variables as an error
#####VARIABLE SET
WHAT=$(ls -lah $1)
PWD=$(pwd)
WHOAMI=$(echo "$(who am i | awk '{print $1}') as $USER")
HOST_NAME=$(hostname -s)


#CODE
if [ -d "./ARCH" ]; then
gzip < $1 > ARCH/$1.$(date +%Y-%m-%d_%H%M).gz
>$1
df -hl

COMPRESSED=$(ls -lah ARCH/$1.$(date +%Y-%m-%d)*.gz)
NOWWHAT=$(ls -lah $1)
echo -e "$WHAT\n$COMPRESSED\n$NOWWHAT"

SUMMARY=$(echo -e "$WHOAMI@$HOST_NAME:$PWD\n$WHAT\n$NOWWHAT")
#C0HGGTPFT
echo -e "\n completed reported to slack"
else
        echo "ARCH directory nonexistent"
fi
