//
//  DBProtocol.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/1.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation

//protocol DBModuleProtocl: ModuleProtocl {
//    var dbModels: [DBModel]? { get }
//}
//
//extension DBModuleProtocl {
//    var dbModels: [DBModel]? { return nil }
//}

protocol DBModel {
    static var dbTableName: String { get }
    static var dbColumns: Dictionary<String, Any> { get }
    static var dbPrimaryKeys: [String]? { get }
    static var dbVersion: Int { get }
    /// 除去增加列以为数据库升级操作。（增加列底层统一处理了）
    static func dbUpgrade(from version: Int, dbName: String, db: FMDatabase)
}

extension DBModel {
    static var dbVersion: Int { return 0 }
    static var dbPrimaryKeys: [String]? { return nil }
    static func dbUpgrade(from version: Int, dbName: String, db: FMDatabase){}
}
