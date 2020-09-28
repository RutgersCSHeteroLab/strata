#!/bin/bash

# Need to pass the number of producer as argument
default=4
producer=${1:-$default}

# Specify the base directories for code and result
STRATA=$PWD
RESULT_BASE=$PWD
result_dir=$RESULT_BASE/scalability/strata


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

let MAX_READER=16
let MAX_WRITER=4

FILESIZE="12G"
FILENAME="testfile"
FSPATH=/mlfs/


# Create output directories
if [ ! -d "$result_dir" ]; then
        mkdir -p $result_dir
fi

if [ ! -d "$result_dir/$producer" ]; then
	mkdir -p $result_dir/$producer
fi

# Create output directory for different number of consumers(readers)
i=1
while (( $i <= $MAX_READER ))
do
	if [ ! -d "$result_dir/$producer/$i" ]; then
		mkdir -p $result_dir/$producer/$i
	fi

	i=$((i*2))
done

sudo dmesg -c

# Setup experiment argument list
ARGS="-j $JOURNAL -k $KERNIO -g $NUMFS -d $DELETEFILE -q $QUEUEDEPTH -s $IOSIZE -t $READERS -u $WRITERS -p $SCHED -v $DEVCORECOUNT -b $FILESIZE"

# First fill up the test file
sudo $STRATA/preload_strata.sh $STRATA/devfs_client_strata -f "$FSPATH/$FILENAME" $ARGS

READERS=1
WRITERS=4
# Vary the number of producer(writer)
while (( $WRITERS <= $MAX_WRITER ))
do
	READERS=1
	# Vary the number of consumer(reader)
	while (( $READERS <= $MAX_READER ))
	do
		ARGS="-j $JOURNAL -k $KERNIO -g $NUMFS -d $DELETEFILE -q $QUEUEDEPTH -s $IOSIZE -t $READERS -u $WRITERS -p $SCHED -v $DEVCORECOUNT -b $FILESIZE"	

		sudo $STRATA/preload_strata.sh $STRATA/devfs_client_strata -f "$FSPATH/$FILENAME" $ARGS &> $result_dir/$WRITERS/$READERS/output.txt

		READERS=$((READERS*2))
	done
	WRITERS=$((WRITERS*2))
done

