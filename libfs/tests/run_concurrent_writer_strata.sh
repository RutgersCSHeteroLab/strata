#!/bin/bash

# Need to pass the number of producer as argument
default=4
producer=${1:-$default}

# Specify the base directories for code and result
STRATA=$PWD
RESULT_BASE=$PWD
result_dir=$RESULT_BASE/stat_conflict/strata


# Setup Parameters
let QSIZE=1
let NUMFS=1
let DELETEFILE=0
let IOSIZE=4096
let JOURNAL=0
let KERNIO=0

let READERS=-1
let WRITERS=-1
let SCHED=0
let DEVCORECOUNT=1
let QUEUEDEPTH=1
let FSYNCFREQ=0

let MAX_READER=16
let MAX_WRITER=16
let MAX_DEVCORECNT=4
let MAX_QUEUEDEPTH=32
let MAX_FSYNCFREQ=64

FILESIZE="12G"
FILENAME="testfile"
FSPATH=/mlfs/

# Create output directories
if [ ! -d "$result_dir" ]; then
        mkdir -p $result_dir
fi

# Create directory for different queue depth and fsync frequency
if [ ! -d "$result_dir/0" ]; then
        mkdir -p $result_dir/0
fi

i=1
while (( $i <= $MAX_WRITER ))
do
        if [ ! -d "$result_dir/$i" ]; then
                mkdir -p $result_dir/$i
        fi
        i=$((i*2))
done

sudo dmesg -c

# Setup experiment argument list
ARGS="-j $JOURNAL -k $KERNIO -g $NUMFS -d $DELETEFILE -q $QUEUEDEPTH -s $IOSIZE -t $READERS -u $WRITERS -p $SCHED -v $DEVCORECOUNT -b $FILESIZE"
# First fill up the test file
sudo $STRATA/preload_strata.sh $STRATA/devfs_client_strata -f "$FSPATH/$FILENAME" $ARGS


let READERS=0
let WRITERS=1
let SCHED=0
let DEVCORECOUNT=$MAX_DEVCORECNT
let QUEUEDEPTH=$MAX_QUEUEDEPTH

# Vary the number of producer(writer)
while (( $WRITERS <= $MAX_WRITER ))
do
	ARGS="-j $JOURNAL -k $KERNIO -g $NUMFS -d $DELETEFILE -q $QUEUEDEPTH -s $IOSIZE -t $READERS -u $WRITERS -p $SCHED -v $DEVCORECOUNT -a $FSYNCFREQ -b $FILESIZE"	
	sudo $STRATA/preload_strata.sh $STRATA/devfs_client_strata -f "$FSPATH/$FILENAME" $ARGS &> $result_dir/$WRITERS/output.txt

        WRITERS=$((WRITERS*2))
done
