#!/bin/bash

# Script to run a command across multiple machines

# Global options

TIMEOUT=10
ERRLOG=/tmp/remote-err-$$
OUTLOG=/tmp/remote-out-$$

# Extract the command line

MACHINES=$1;shift
COMMAND=$1;shift

for machine in $MACHINES
do
    echo ======================================================>> $OUTLOG.$machine.log
    echo ======================================================>> $OUTLOG.$machine.log
    echo Start date: `date` >>$OUTLOG.$machine.log
    echo Processing: $machine >>$OUTLOG.$machine.log
    echo Running command: $COMMAND >>$OUTLOG.$machine.log
    echo --------- OUTPUT --------->> $OUTLOG.$machine.log
    ssh -oConnectTimeout=$TIMEOUT $machine $COMMAND >>$OUTLOG.$machine.log
        2>>$ERRLOG.$machine.log &

    echo >> $OUTLOG.$machine.log
    echo End date: `date` >>$OUTLOG.$machine.log
    echo >> $OUTLOG.$machine.log
    echo >> $OUTLOG.$machine.log
done

# Wait for children to finish

wait

cat $OUTLOG.*
#cat $OUTLOG.* | mail -s "Output Message" me@email.com


#cat $ERRLOG.* >&2
#rm -f $OUTLOG.* $ERRLOG.*

