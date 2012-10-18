#!/bin/sh

echo "Get submodules"
SUBMODULE=`git submodule | awk '{print $2}'`

if [ "x$1" = "xtest" ]; then
  sh $0 init
  (cd madwifi-brn; make)
  if [ $? -ne 0 ]; then
    echo "Madwifi failed"
    exit 1
  fi
  (cd compat-wireless-brn; NOCROSS=1 KERNELPATH=/usr/src/linux-headers-2.6.32-30-generic ./wifidriver.sh build)
  if [ $? -ne 0 ]; then
    echo "compat-wireless-brn failed"
    exit 1
  fi
fi

if [ "x$1" = "xinit" ]; then
  echo "brn-driver"
  git submodule init
  git submodule update
  for i in $SUBMODULE; do echo $i; (cd $i; git checkout master); done
  (cd compat-wireless-brn/brn-linux-next; git checkout brn-master)
fi

if [ "x$1" = "xpull" ]; then
  echo "brn-driver"
  git pull
  for i in $SUBMODULE; do echo $i; (cd $i; git pull); done
  exit 0
fi

if [ "x$1" = "xstatus" ]; then
  echo "brn-driver"
  git status
  for i in $SUBMODULE; do echo $i; (cd $i; git status); done
  exit 0
fi

if [ "x$1" = "xbuild-modules" ]; then
  DRIVER=$2

  case "$DRIVER" in
    "madwifi")
      if [ -e $KERNELDIR ]; then
        echo "Build $DRIVER for $ARCH"
        (cd madwifi-brn; make clean; make -j 4 KERNELPATH=$KERNELDIR ARCH=$ARCH CROSS_COMPILE=$COMPILER_PREFIX)
        if [ ! -e $TARGETDIR ]; then
          mkdir -p $TARGETDIR
        fi
        (cd madwifi-brn;find . -name "*.ko" -print0 | xargs -0 cp --target=$TARGETDIR)
      fi
      ;;
    "ath")
      if [ -e $KERNELDIR ]; then
        echo "Build $DRIVER for $ARCH"
        (cd compat-wireless-brn; KERNELDIR=$KERNELDIR ARCH=$ARCH COMPILER_PREFIX=$COMPILER_PREFIX ./wifidriver.sh build)
        if [ ! -e $TARGETDIR ]; then
          mkdir -p $TARGETDIR
        fi
        (cd compat-wireless-brn; TARGETDIR=$TARGETDIR ./wifidriver.sh copy)
      fi
      ;;
      *)
      echo "Driver $DRIVER is unknown!"
      exit -1
      ;;
  esac
fi
