#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
print("检测 特殊资源 是否 加入了 app 包...")
print("usage: python3 resourceCheck.py app地址 plist文件地址")

import os
import sys
import plistlib

appPath = ""
resourcePath = ""
# 获取命令行参数
if len(sys.argv) == 3:
	# print(sys.argv[1])
	appPath = sys.argv[1] #"/Users/dxw/Desktop/back/KVOTest/DerivedData/KVOTest/Build/Products/Debug-iphonesimulator/KVOTest.app"
	resourcePath = sys.argv[2] #"/Users/dxw/Desktop/back/KVOTest/KVOTest/res.plist"
else:
	print("请输入app路径-------")

# 读取待检测文件
with open(resourcePath,'rb') as fp:
	pl = plistlib.load(fp)
	targetFiles = pl
	
# 检测文件是否存在
for f in targetFiles:
	path = os.path.join(appPath,f)
	if not os.path.exists(path):
		print(f,"不存在")
		

