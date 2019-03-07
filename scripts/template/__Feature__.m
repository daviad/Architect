//
//  {ClassName}.h
//  {ProjectName}
//
//  Created by {UserName} on {Today}.
//  Copyright © 2017年 Real Cloud. All rights reserved.
//

#import "{ClassName}.h"

@implementation {ClassName}

/**
 描述表的访问权限，若不实现，默认是LCResAccessRole_User，即登录用户
 
 @return LCResAccessRole的任意一种
 */
// - (LCResAccessRole)accessRoles {
//     return LCResAccessRole_User;
// }

/**
 描述在该feature内定义的数据库模型
 
 @return 返回数据库模型的类的名字的列表，如 ["StudentModel"]
 */
// - (NSArray *)allDBModels {
//     return @[
//              // list of class or class name
//              ];
// }

/**
 描述feature的版本信息
 
 @return 返回版本的int值，默认为0
 */
// - (int)featureVersion {
//     return 0;
// }

/**
 对feature进行升级，主要处理缓存文件的变更，比如清理不再使用的老数据
 
 @param version : 上个版本号
 @param accessor : 访问者
 @return 如果升级成功返回YES
 */
// - (BOOL)upgradeFromVersion:(int)version forAccessor:(LCResAccessor *)accessor {
//     return YES;
// }

/**
 之前登录过，本次读取登录记录，为登录做准备
 
 @param accessor : 作为某个用户角色
 */
// - (void)prepareForAccessor:(LCResAccessor *)accessor {
// }

/**
 登录成功
 
 @param accessor : 作为某个用户角色
 @param autoLogin : 是否是自动登录的
 */
// - (void)didLoginAsAccessor:(LCResAccessor *)accessor autoLogin:(BOOL)autoLogin {
// }

/**
 注销完成
 
 @param accessor : 作为某个用户角色
 */
// - (void)didLogoutAsAccessor:(LCResAccessor *)accessor {
// }

@end
