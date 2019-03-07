#!/bin/sh
#根据编译条件 拷贝bundle 到 app包
BUNDLE[0]=$SRCROOT/../../Frameworks/ATSDK.framework/Resources/ATSDK.bundle

BUILD_APP_DIR=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app

if [ "$CONFIGURATION" == "Debug" ]; then
	for BUNDLE in ${BUNDLE[@]}; do
		cp -f -r $BUNDLE $BUILD_APP_DIR
	done
fi