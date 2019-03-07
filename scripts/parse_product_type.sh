#!/bin/sh

#define LOOCHA_PRODUCT_LoochaCampus    1
#define LOOCHA_PRODUCT_PocketCampus    2
#define LOOCHA_PRODUCT_SchoolyardCloud 3
#define LOOCHA_PRODUCT_CoolYouth       4

#BUILT_PRODUCTS_DIR
#LOOCHA_PRODUCT=1

#mkdir -p ${BUILT_PRODUCTS_DIR}
#ProductTypePath=${BUILT_PRODUCTS_DIR}/product_type
loocha_xcode_path=/tmp/loocha_xcode
mkdir -p ${loocha_xcode_path}
ProductTypePath=${loocha_xcode_path}/product_type

LOOCHA_PRODUCT=0

case ${TARGET_NAME} in
'LoochaCampus')
LOOCHA_PRODUCT=1
;;

'PocketCampus')
LOOCHA_PRODUCT=2
;;

'SchoolyardCloud')
LOOCHA_PRODUCT=3
;;

'CoolYouth')
LOOCHA_PRODUCT=4
;;
esac

echo "LOOCHA_PRODUCT=${LOOCHA_PRODUCT}" > ${ProductTypePath}

