#!/bin/sh

#
# 多个工程共享公共资源，在编译后，拷贝到app包内
# 公共资源是公共模块生成的CommonResource.bundle
#

TargetFolderPath="$BUILT_PRODUCTS_DIR/${CONTENTS_FOLDER_PATH}"
SourceFolderPath="${BUILT_PRODUCTS_DIR}/CommonResource.bundle"


#这个会把Info.plist也考到app里，会覆盖掉app的Info.plist
#cp -R "${SourceFolderPath}/" "${TargetFolderPath}"

find ${SourceFolderPath} -depth 1 ! -name "Info.plist" | xargs -I {} cp -R {} ${TargetFolderPath}

#BUILT_PRODUCTS_DIR
#FULL_PRODUCT_NAME

#CODESIGNING_FOLDER_PATH
#EXECUTABLE_FOLDER_PATH
#CONTENTS_FOLDER_PATH
#CODESIGNING_FOLDER_PATH=/Users/zhangjinquan/workspace/realcloud/LoochaCampus/trunk_10_24/DerivedData/Build/Products/Release-iphonesimulator/LoochaCampus.app