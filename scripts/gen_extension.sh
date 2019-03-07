#!/bin/sh

#
# function:自动生成extension
# usage:   sh gen_extension.sh [extension_name]
#

ExtensionName=""
ProjectName="LoochaCampus"

if [[ $# < 1 ]]; then
	echo "请输入extension的名字:"
	read ExtensionName
else
	ExtensionName=$1
fi

ExtFolder="${ExtensionName}.extension"
Count=2

while [[ -e $ExtFolder ]]; do
	ExtFolder="${ExtensionName}_${Count}.extension"
	Count=$[$Count + 1]
done

echo "正在生成扩展($ExtFolder)..."

mkdir "$ExtFolder"
ExtFolder="$ExtFolder/${ExtensionName}"
mkdir "$ExtFolder"
mkdir "$ExtFolder/Controllers"
mkdir "$ExtFolder/Views"
mkdir "$ExtFolder/ViewModel"
mkdir "$ExtFolder/Handlers"
mkdir "$ExtFolder/DAO"
mkdir "$ExtFolder/Models"

TemplateDir="../templates/extension/"

FullUsername=$(finger `whoami` | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //')
Today=$(date +%y-%m-%d)

# db header ---------------------

cat > "$ExtFolder/Models/${ExtensionName}_db.h" <<EOF
//
//  ${ExtensionName}_db.h
//  ${ProjectName}
//
//  Created by ${FullUsername} on ${Today}.
//
//

#ifndef ${ProjectName}_${ExtensionName}_db_h
#define ${ProjectName}_${ExtensionName}_db_h



#endif
EOF

# constants header ------------------

ExtentClass="${ExtensionName}_constants"

cat > "$ExtFolder/${ExtentClass}.h" <<EOF
//
//  ${ExtentClass}.h
//  ${ProjectName}
//
//  Created by ${FullUsername} on ${Today}.
//
//

#ifndef ${ProjectName}_${ExtensionName}_constants_h
#define ${ProjectName}_${ExtensionName}_constants_h

//SAMPLE: #define Request_Syncfile_before             @""kSchemeURLPath"/%@/file?before=%@&limit=500"

typedef enum {
    kTaskMsg_${ExtensionName}_Base = MsgBaseOfExtension(kExtID_${ExtensionName}),
} TaskMsg_${ExtensionName};

#endif
EOF

cat > "$ExtFolder/${ExtensionName}Extension.h" <<EOF
//
//  ${ExtensionName}Extension.h
//  ${ProjectName}
//
//  Created by ${FullUsername} on ${Today}.
//
//

#import <Foundation/Foundation.h>
#import "LoochaExtension.h"

@interface ${ExtensionName}Extension : NSObject <LoochaExtension>

@end
EOF

cat > "$ExtFolder/${ExtensionName}Extension.m" <<EOF
//
//  ${ExtensionName}Extension.m
//  ${ProjectName}
//
//  Created by ${FullUsername} on ${Today}.
//
//

#import "${ExtensionName}Extension.h"

@implementation ${ExtensionName}Extension

+ (ExtensionID)extensionID
{
    return kExtID_${ExtensionName};
}

+ (NSDictionary *)tableColumnMapping
{
    return nil;
}

+ (void)updateDBOnLaunching:(FMDatabase *)db
{
}

+ (BOOL)autoHttpGetTaskMsg:(int)taskMsg
{
    return NO;
}

+ (BOOL)handleResourceMessage:(LFMessage *)msg
{
    int messageType = msg.taskMsg;
    id arg = msg.argument;
    if (0) {

    }
    else {
        return NO;
    }
    return YES;
}

+ (BOOL)handleOnRootController:(LoochaRootController *)rootController message:(int)messageType withResult:(int)result withArg:(id)arg
{
    if (0) {

    }
    else {
        return NO;
    }
    return YES;
}

@end
EOF

echo "生成扩展($ExtFolder)完成"