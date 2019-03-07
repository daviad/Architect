#!/bin/sh

CUR_PATH=$PWD
cd $PROJECT_DIR/../../lib

if [ -e libidn.a ]; then
   rm libidn.a
fi

if [ "$PLATFORM_NAME" = "iphoneos" ]; then
    ln -s libidn-armv7.a libidn.a
else
    ln -s libidn-i386.a libidn.a
fi
cd $CUR_PATH
