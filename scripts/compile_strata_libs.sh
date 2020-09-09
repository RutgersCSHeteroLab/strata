#! /bin/bash

BASE=$PWD

set -x

sudo apt-get install libssl-dev gawk libaio-dev libcunit1-dev autoconf dh-autoreconf asciidoctor asciidoc pandoc libkmod-dev libudev-dev uuid-dev libjson-c-dev librdmacm-dev libibverbs-dev libkeyutils-dev cmake pkg-config libcapstone-dev

# Set NVM private log size to be 4GB, NVM FS storage size to be 16GB
./utils/change_dev_size.py 16 0 0 4

# Build required libs
cd $BASE/libfs/lib

# Get NDCTL Library
git clone https://github.com/pmem/ndctl

cd ndctl
./autogen.sh
./configure CFLAGS='-g -O2' --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib
make
make check
sudo make install
cd ..
rm -rf ndctl

# Get NVML Library
git clone https://github.com/pmem/nvml
git clone https://github.com/pmem/syscall_intercept.git
make

# Overwrite NDCTL Library with version 57 makes it runs on cloudlab
wget https://github.com/pmem/ndctl/archive/v57.tar.gz
tar -zxvf v57.tar.gz
cd ndctl-57/
#git clone https://github.com/pmem/ndctl
#cd ndctl
./autogen.sh
./configure CFLAGS='-g -O2' --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib
make
make check
sudo make install
cd ..

# Build jemalloc
cd $BASE/libfs/lib
tar xvjf jemalloc-4.5.0.tar.bz2
cd jemalloc-4.5.0
./autogen
./configure
make

cd $BASE/libfs
make
cd tests
make

cd $BASE/kernfs
make
cd tests
make

set +x
