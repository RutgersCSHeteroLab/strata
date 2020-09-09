#! /bin/bash

PARA=16

set -x

#cd kernel/kbuild
#cd kernel/linux-4.8.12

#make -f Makefile.setup .config
#make -f Makefile.setup
#sudo make -j$PARA
#sudo make modules -j$PARA
#sudo make modules_install
#sudo make install

#set +x
#exit


cd kernel/linux-4.8.12

sudo cp mlfs.config .config
sudo apt-get install libdpkg-dev kernel-package

export CONCURRENCY_LEVEL=$PARA
touch REPORTING-BUGS
sudo fakeroot make-kpkg -j$PARA --initrd kernel-image kernel-headers
sudo dpkg -i ../*image*.deb ../*header*.deb


set +x
