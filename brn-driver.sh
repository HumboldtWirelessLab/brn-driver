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
  (cd compat-wireless-brn; NOCROSS=1 ./wifidriver.sh build)
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
