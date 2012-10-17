#!/bin/sh

for i in `ls /testbedhome/testbed/helper/nodes/lib/modules/mips`; do
#  echo $i
  if [ -e /testbedhome/testbed/software/kernel-mips/linux-$i ]; then
    echo "Build $i (source)"
    (cd madwifi-brn; make clean; make -j 4 KERNELPATH=/testbedhome/testbed/software/kernel-mips/linux-$i ARCH=mips CROSS_COMPILE=mipsel-linux-)
    (cd madwifi-brn;find . -name "*.ko" -print0 | xargs -0 cp --target=/testbedhome/testbed/helper/nodes/lib/modules/mips/$i)
  fi
done

for i in `ls /testbedhome/testbed/helper/nodes/lib/modules/i586`; do
#  echo $i
  if [ -e /testbedhome/testbed/software/kernel-x86/linux-$i ]; then
    echo "Build $i (source)"
    (cd madwifi-brn; make clean; make -j 4 KERNELPATH=/testbedhome/testbed/software/kernel-x86/linux-$i ARCH=i386 CROSS_COMPILE=i386-linux-)
    (cd madwifi-brn;find . -name "*.ko" -print0 | xargs -0 cp --target=/testbedhome/testbed/helper/nodes/lib/modules/i586/$i)
  fi
  if [ -e /testbedhome/testbed/software/kernel-x86/linux-headers-$i ]; then
    echo "Build $i (header)"
    (cd madwifi-brn; make clean; make -j 4 KERNELPATH=/testbedhome/testbed/software/kernel-x86/linux-headers-$i ARCH=i386 CROSS_COMPILE=i386-linux-)
    (cd madwifi-brn;find . -name "*.ko" -print0 | xargs -0 cp --target=/testbedhome/testbed/helper/nodes/lib/modules/i586/$i)
  fi
done
