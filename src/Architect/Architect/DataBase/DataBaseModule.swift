//
//  DataBaseModule.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/2/28.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
final class DataBaseModule: ModuleProtocl {
    
    func load() {
        
    }
    func setup() {
        
// 创建数据库 路径，
//      根据 注册的module 创建对应模型的 数据库
        configDBQueue()
        createDB()
    }
    
    func configDBQueue() {
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
                    dbPath = (dbPath as NSString).appendingPathComponent("1.db")
                    try $0.executeUpdate("ATTACH DATABASE '\(dbPath)' as \("pub") ", values: nil)
                } catch  {
                    print($0.lastErrorMessage())
                }
            }
        }
    }
    
    func crateTables() {
        _ = ModuleManager.shared.modules.map { modules in
            if let models = modules.dbModels {
                _ = models.map { m in
                    let sql = DBHelper.buildCreateTableSql(dbModel: type(of: m), dbName: "pub")
                    DBHelper.shared.executionQueue.async(flags: .barrier) {
                        DBHelper.shared.executionQueue.async(flags: .barrier) {
                            DBHelper.shared.dbQueue.inDatabase {
                                try? $0.executeUpdate(sql, values: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
