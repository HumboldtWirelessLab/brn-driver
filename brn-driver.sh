#!/bin/sh

if [ "x$CPUS" = "x" ]; then
  if [ -f /proc/cpuinfo ]; then
    CPUS=`grep -e "^processor" /proc/cpuinfo | wc -l`
  else
    CPUS=1
  fi
fi

echo "Get submodules"
SUBMODULE=`git submodule | awk '{print $2}'`

if [ "x$1" = "xtest" ]; then
  sh $0 init
  (cd madwifi-brn; make clean; make)
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
  for i in $SUBMODULE; do SI=0; if [ ! -e $i/.git ] && [ $SI -eq 0 ]; then git submodule init; SI=1; fi; done
  git submodule update
  for i in $SUBMODULE; do echo $i; (cd $i; git checkout master); done
  #(cd compat-wireless-brn/brn-linux-next; git checkout brn-master)
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
      if [ -e $KERNELPATH ]; then
        echo "Build $DRIVER for $ARCH"

        if [ -f madwifi-brn/.last_build ]; then
          . madwifi-brn/.last_build
        fi

        if [ "x$KERNELPATH" = "x$BUILDKERNEL" ] && [ "x$ARCH" = "x$BUILDARCH" ]; then
          (cd madwifi-brn; make -j $CPUS KERNELPATH=$KERNELPATH ARCH=$ARCH CROSS_COMPILE=$COMPILER_PREFIX)
        else
          (cd madwifi-brn; make clean; make -j $CPUS KERNELPATH=$KERNELPATH ARCH=$ARCH CROSS_COMPILE=$COMPILER_PREFIX)
          (cd madwifi-brn; echo -e "BUILDKERNEL=$KERNELPATH\nBUILDARCH=$ARCH" > .last_build)
        fi

        if [ ! -e $TARGETDIR ]; then
          mkdir -p $TARGETDIR
        fi
        (cd madwifi-brn;find . -name "*.ko" -print0 | xargs -0 cp --target=$TARGETDIR)
      fi
      ;;
    "ath")
      if [ -e $KERNELPATH ]; then
        echo "Build $DRIVER for $ARCH"
        (cd compat-wireless-brn; KERNELPATH=$KERNELPATH ARCH=$ARCH COMPILER_PREFIX=$COMPILER_PREFIX ./wifidriver.sh build)
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
