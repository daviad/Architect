//
//  DataBaseModule.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/2/28.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation

/// 完成数据库模块的加载、设置，及数据库及数据库表的配置、创建、升级、清理
final class DataBaseModule: ModuleProtocl {
    
    func load() {
    }
    func setup() {
        configDB()
        createDB()
        crateTables()
        dbUpgrade()
    }
    
    func configDB() {
        DBHelper.shared.executionQueue.async(flags: .barrier) {
            DBHelper.shared.dbQueue.inDatabase { $0.shouldCacheStatements = true}
        }
    }
    
    func clearDBCache() {
        DBHelper.shared.executionQueue.async(flags: .barrier) {
            DBHelper.shared.dbQueue.inDatabase{ $0.clearCachedStatements() }
        }
    }
    
    func createDB() {
        DBHelper.shared.executionQueue.async(flags: .barrier) {
            DBHelper.shared.dbQueue.inDatabase {
                do {
                    var  dbPath = SandboxManager.shared.buildFolderPath(type: .document, "db")!
                    dbPath = (dbPath as NSString).appendingPathComponent("\(String(AppSession.shared.user.id)).db")
                    try $0.executeUpdate("ATTACH DATABASE '\(dbPath)' as \("\(AppSession.shared.accessor.role.rawValue)") ", values: nil)
                } catch  {
                    print($0.lastErrorMessage())
                }
            }
        }
    }
    
    func crateTables() {
        _ = ModuleManager.shared.modules.map { module in
            if let models = module.dbModels {
                _ = models.map { m in
                    let sql = DBHelper.buildCreateTableSql(dbModel: type(of: m), dbName: AppSession.shared.accessor.role.rawValue)
                    DBHelper.shared.executionQueue.async(flags: .barrier) {
                        DBHelper.shared.dbQueue.inDatabase {
                            try? $0.executeUpdate(sql, values: nil)
                        }
                    }
                }
            }
        }
    }
    
    func dbUpgrade() {
        _ = ModuleManager.shared.modules.map { module in
            if let models = module.dbModels {
                _ = models.map { m in
                    DBHelper.shared.executionQueue.async(flags: .barrier) {
                        DBHelper.shared.upgradeTable(dbModel: type(of: m), dbName: AppSession.shared.accessor.role.rawValue)
                    }
                }
            }
        }
    }
    
    var dbModels: [DBModel]? {
        return [DBModelVersion()]
    }
}
