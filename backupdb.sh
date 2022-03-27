#!/bin/bash
#===============================================================================
#
#          FILE: backupdb.sh
#
#         USAGE: ./backupdb.sh
#
#  DESCRIPTION: This script is designed to backup database
#               It could be run on a daily or weekly basis as a cronjob
#       OPTIONS: No options are required
#  THE SCRIPT DO:
#                 create a directory, dump database to the directory, compres the sql dump file(s)
#		  and removes all existing .sql & .gz file thats are +30 day old.                                                   
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ruudgong
#  ORGANIZATION: 
#       CREATED: 04/24/2016 
#      REVISION: 03
#===============================================================================

USER="root"
PASSWORD="password"
OUTPUT="/tmp/athena-db-sqldump"
date=$(date +%Y%m%d)

if [[ ! -e $OUTPUT ]] ; then
        mkdir -p $OUTPUT
fi

rm "$OUTPUT/*.tgz" > /dev/null 2>&1
rm "$OUTPUT/*.gz" > /dev/null 2>&1
rm "$OUTPUT/*.sql" > /dev/null 2>&1
find $OUTPUT/* -name *.gz -mtime +30 -exec rm {} \; > /dev/null 2>&1
find $OUTPUT/* -name *.sql -mtime +30 -exec rm {} \; > /dev/null 2>&1

databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] && [[ "$db" != "performance_schema" ]]; then
        #echo "Dumping database: $db"
        filename="$date.$db.sql"
        mysqldump --events --force --opt --user=$USER --password=$PASSWORD --databases $db > $OUTPUT/$filename
    fi
done

tar -czf "$OUTPUT/athena-mysqldump-$date.tgz" $OUTPUT/*.sql 2>/dev/null
