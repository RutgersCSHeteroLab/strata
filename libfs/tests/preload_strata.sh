#! /bin/bash

PATH=$PATH:.

STRATASRC=../..

export LD_LIBRARY_PATH=$STRATASRC/libfs/lib/nvml/src/nondebug/:$STRATASRC/libfs/build

LD_PRELOAD=$STRATASRC/libfs/lib/jemalloc-4.5.0/lib/libjemalloc.so.2 ${@}
#LD_PRELOAD=../../shim/libshim/libshim.so:../lib/jemalloc-4.5.0/lib/libjemalloc.so.2 MLFS_PROFILE=1 ${@}
