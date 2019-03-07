#!/bin/sh  

# 链接：https://www.jianshu.com/p/3668979476ad
# 链接：http://www.cocoachina.com/ios/20181010/25134.html
# 读取用户输入并存到变量里
# read parameter
# sleep 0.5

echo "~~~~~~~~~~~~第一个参数：打包方式(输入序号)~~~~~~~~~~~~~~~"
echo "  1 Develope Debug"
echo "  2 Develope Release"
echo "  3 AppStore"
echo "  4 Enterprise"
echo "  5 adHoc"

echo "~~~~~~~~~~~~第二个参数：选择服务器(输入序号)~~~~~~~~~~~~~~~"
echo "  1 测试服"
echo "  2 运营服"

echo "~~~~~~~~~~~~第三个参数：工程目录 ~~~~~~~~~~~~~~~"
echo "  如/Users/dxw/Desktop/github/LoochaCampusSwift"

echo "~~~~~~~~~~~~第四个参数：target TargetName (可选)~~~~~~~~~~~~~~~"
echo "  如PocketCampus"

if [ $# < 3 ]
then
    echo "erro: 请输入合适的参数!!!!!!"
    exit -1
fi

method=$1
serverHost=$2
#工程名字(Target名字)

TargetName="PocketCampus"
if [[ -n "$4" ]]; then
    TargetName=$4
fi

ProjectRoot=$3
# ProjectRoot="/Users/dxw/Desktop/github/LoochaCampusSwift"
#Configuration="Release" 
# Configuration="Debug"
#AppStore版本的Bundle ID, 开发版本也是这个
AppStoreBundleID="cn.realcloud.Loocha.pocketcampus"
#enterprise的Bundle ID
EnterpriseBundleID="com.xxxx"
#AdHoc版本的Bundle ID
AdHocBundleID="com.xxxx"

#开发版本 Debug
DEVELOPE_DEBUG_SIGN_IDENTITY="iPhone Developer"
DEVELOPE_DEBUG_ROVISIONING_PROFILE_NAME="archive-devel-pocketcampus"

#开发版本 Release
DEVELOPE_Release_SIGN_IDENTITY="iPhone Developer"
DEVELOPE_Release_ROVISIONING_PROFILE_NAME="archive-devel-pocketcampus"

#AppStore证书名#描述文件
APPSTORECODE_SIGN_IDENTITY="iPhone Distribution"
APPSTOREROVISIONING_PROFILE_NAME="LoochaCampus_distro_2016_12_07"

# ADHOC证书名#描述文件
ADHOCCODE_SIGN_IDENTITY="iPhone Distribution: xxxx"
ADHOCPROVISIONING_PROFILE_NAME="xxxxx-xxxx-xxxx-xxxx-xxxxxx"

#企业(enterprise)证书名#描述文件
ENTERPRISECODE_SIGN_IDENTITY="iPhone Distribution: xxxx"
ENTERPRISEROVISIONING_PROFILE_NAME="xxxxx-xxxx-xxx-xxxx"

#加载各个版本的plist文件
DEVELOPE_DEBUG_ExportOptionsPlist=${ProjectRoot}"/archived/exportOption/DevelopExportOptions.plist"
DEVELOPE_Release_ExportOptionsPlist=${DEVELOPE_DEBUG_ExportOptionsPlist}
AppStoreExportOptionsPlist=${ProjectRoot}"/archived/exportOption/AppStoreExportOptionsPlist.plist"
EnterpriseExportOptionsPlist=${ProjectRoot}"/archived/exportOption/EnterpriseExportOptionsPlist.plist"
ADHOCExportOptionsPlist=${ProjectRoot}"/archived/exportOption/ADHOCExportOptionsPlist.plist"

# #因为Jenkins打包可能是自动的，那么build号是不会自己再去修改然后push到git上面的，所以这个buildPlist就是修改build号的路径。 
# buildPlist="/Users/apple/.jenkins/workspace/longxin_a/eCloud/Build/LongHu/Config/eCloud-Info.plist"

#  #这个获取现在的 月日时分 用它来做build号 
# buildNumber=$(date +"%m%d%H%M")
#  #修改plist文件需要/usr/libexec/PlistBuddy -c命令，CFBundleVersion是修改的这个build号，$buildNumber是你要修改的数值，$buildPlist是你修改哪个地方的plist文件。
#  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$buildPlist"  

#  #这个是获取当前的build号，本来是用来看看有没有修改成功的 
# newBuildName=$(/usr/libexec/PlistBuddy -c "print :CFBundleVersion" "$buildPlist") 

#  #这个是打印，带自动换行的打印 
#  echo $newBuildName   

#  #因为我怕他修改plist的时候需要时间，所以索性在这里我让他等了3秒，当然你也可以去掉 
#  sleep 3  
#这个buildPath是到时候我生成xcarchive文件的路径和打ipa时候需要找到xcarchive的路径
# dateString=$(date +"%m-%d-%H-%M")
dateString=$(date +"%Y-%m-%d")
timeString=$(date +"%H-%M")
buildPath=$ProjectRoot"/archived/xcarchive/"${dateString}"/"${timeString}"/"
#这个路径是我生成ipa的路径 
ipaPath=$ProjectRoot"/archived/ipa/"${dateString}"/"${timeString}"/"



#将自动签名改我手动签名
sed -i "" "s/ProvisioningStyle = Automatic/ProvisioningStyle = Manual/g" ${ProjectRoot}"/Main/src/LoochaCampus/LoochaCampus.xcodeproj/project.pbxproj"

echo product root path: $buildPath
echo $ipaPath

#app store 版本 必须是运营服
if [ "$method" = "3" ]
then
    serverHost=2
fi

serverDir=""

# 1 测试服"
if [ "$serverHost" = "1" ]
then
    serverDir="_test"
    sed -i "" "s/#define PRODUCT_TEST[[:space:]]*0/#define PRODUCT_TEST      1/g" ${ProjectRoot}"/Main/src/LoochaCampusMain/LoochaCampusMain/OC/ProductConfigure/Product.h"
    sed -i "" "s/#define USE_TEST_SERVER[[:space:]]*0/#define USE_TEST_SERVER    1/g" ${ProjectRoot}"/Main/src/LoochaCampusMain/LoochaCampusMain/OC/ProductConfigure/ProductConfig.h"
    echo "测试服版本。。。。。"
elif [ "$serverHost" = "2" ]
then
    serverDir="_server"
    if [ "$method" = "3" ]
    then
        sed -i "" "s/#define PRODUCT_TEST[[:space:]]*1/#define PRODUCT_TEST      0/g" ${ProjectRoot}"/Main/src/LoochaCampusMain/LoochaCampusMain/OC/ProductConfigure/Product.h"
    fi

    
    sed -i "" "s/#define USE_TEST_SERVER[[:space:]]*1/#define USE_TEST_SERVER    0/g" ${ProjectRoot}"/Main/src/LoochaCampusMain/LoochaCampusMain/OC/ProductConfigure/ProductConfig.h"
    echo "运营服版本。。。。。"
fi

# 判读用户是否有输入
if [ -n "$method" ]
then
    if [ "$method" = "1" ]
    then
    	echo "start Develope debug archive......"
    	buildPath=${buildPath}"developeDebug/"${TargetName}
    	ipaPath=${ipaPath}"developeDebug${serverDir}/"
    	#Develope Debug 脚本
    	xcodebuild -workspace $ProjectRoot"/Main/LoochaCampusSwift.xcworkspace" -scheme ${TargetName} -archivePath ${buildPath} -configuration Debug CODE_SIGN_IDENTITY="${DEVELOPE_DEBUG_SIGN_IDENTITY}" PROVISIONING_PROFILE="${DEVELOPE_DEBUG_ROVISIONING_PROFILE_NAME}" PRODUCT_BUNDLE_IDENTIFIER="${AppStoreBundleID}" -verbose archive
    	echo "start expoert archive......"
        xcodebuild -exportArchive -archivePath ${buildPath}".xcarchive" -exportPath ${ipaPath} -exportOptionsPlist ${DEVELOPE_DEBUG_ExportOptionsPlist}
    elif [ "$method" = "2" ]
    then
       #Develope Release 脚本
        echo "start Develope Release archive....."
    	buildPath=${buildPath}"DevelopeRelease/"${TargetName}
    	ipaPath=${ipaPath}"developeRelease${serverDir}/"
    	xcodebuild -workspace $ProjectRoot"/Main/LoochaCampusSwift.xcworkspace" -scheme ${TargetName} -archivePath ${buildPath} -configuration Release CODE_SIGN_IDENTITY="${DEVELOPE_Release_SIGN_IDENTITY}" PROVISIONING_PROFILE="${DEVELOPE_Release_ROVISIONING_PROFILE_NAME}" PRODUCT_BUNDLE_IDENTIFIER="${AppStoreBundleID}" -verbose archive
    	echo "start export archive......"
        xcodebuild -exportArchive -archivePath ${buildPath}".xcarchive" -exportPath ${ipaPath} -exportOptionsPlist ${DEVELOPE_Release_ExportOptionsPlist}

    elif [ "$method" = "3" ]
    then
    	#app store 
    	echo "start Develope appstore archive....."
    	buildPath=${buildPath}"appstore"/${TargetName}
    	ipaPath=${ipaPath}"appstore/"
    	xcodebuild -workspace $ProjectRoot"/Main/LoochaCampusSwift.xcworkspace" -scheme ${TargetName} -archivePath ${buildPath} -configuration Release CODE_SIGN_IDENTITY="${APPSTORECODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${APPSTOREROVISIONING_PROFILE_NAME}" PRODUCT_BUNDLE_IDENTIFIER="${AppStoreBundleID}" -verbose archive
    	echo "start exportArchive"
        xcodebuild -exportArchive -archivePath ${buildPath}".xcarchive" -exportPath ${ipaPath} -exportOptionsPlist ${AppStoreExportOptionsPlist}

    elif [[ "$method" = "4" ]]
    then
	#企业打包脚本
	echo "start Develope enterprise archive....."
    	buildPath=${buildPath}"enterprise/"${TargetName}
    	ipaPath=${ipaPath}"enterprise${serverDir}/"
	xcodebuild -workspace $ProjectRoot"/Main/LoochaCampusSwift.xcworkspace" -scheme ${TargetName} -archivePath ${buildPath} -configuration Release CODE_SIGN_IDENTITY="${ENTERPRISECODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${ENTERPRISEROVISIONING_PROFILE_NAME}" PRODUCT_BUNDLE_IDENTIFIER="${EnterpriseBundleID}" -verbose archive
    xcodebuild -exportArchive -archivePath ${buildPath}".xcarchive" -exportPath ${ipaPath} -exportOptionsPlist ${EnterpriseExportOptionsPlist}

    else
    echo "参数无效...."
    exit 1
    fi
fi

ipaPathTmp=${ipaPath}${TargetName}".ipa"

# 上传蒲公英  这部分有 jenkins 实现 更合理
# if [ -n "$ipaPathTmp" ]
# then
#     if [ "$method" != "3" ]
#     then
#         PGY_API_Key="817254a4738bce11219ca7af1632d325"
#         PGY_User_Key="f32301b93b3c0ad5404411f2884cc293"
#         curl -F "file=@${ipaPathTmp}" -F "uKey=${PGY_User_Key}" -F "_api_key=${PGY_API_Key}" https://qiniu-storage.pgyer.com/apiv1/app/upload
#     fi
# fi


#  #上传 testflight  这个比较还是用 xcode  上传吧 双击 XXX.xcarchive 文件
#  #https://blog.csdn.net/sinat_25544827/article/details/54314105
#  #1. 验证IPA
#  altool -v -f /Users/kimilin/Downloads/test.ipa -u example@test.com -p YourPassword -t ios
#  #2. 上传IPA
# altool --upload-app -f /Users/kimilin/Downloads/test.ipa -t ios -u example@test.com -p YourPassword
