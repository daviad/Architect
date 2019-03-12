//
//  DBHelper.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/4.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
import HandyJSON

struct DBConstants {
    
    enum DataType: String {
        case text = "TEXT"
        case integer, bool = "INTEGER"
        case real = "REAL"
        case bigInt = "BIGINT"
        case blob = "BLOB"
    }
    //    static let dbText = "TEXT"
    //    static let text = "TEXT"
    //    static let integer = "INTEGER"
    //    static let real = "REAL"
    //    static let bigInt = "BIGINT"
    //    static let bool = "INTEGER"
    //    static let blob = "BLOB"
    
    static let PrimaryKey = "PRIMARY KEY"
    static let notNull = "NOT NULL"
    static let unique = "UNIQUE"
}

extension FMResultSet {
    //将close封装起来以免遗漏
    fileprivate func enumerate<T: Model>(_ modelType: T.Type, _ results: inout [T]) {
        while self.next() {
            let dic = self.resultDictionary as? [String : Any]
            if let model = modelType.deserialize(from: dic) {
                results.append(model as T)
            }
        }
        self.close()
    }
    
    func arrayOfModelType<T: Model>(_ modelType: T.Type) -> [T] {
        var results = [T]()
        enumerate(modelType, &results)
        return results
    }
}

extension Dictionary {
    //    func
}

final class DBHelper {
    
    let dbQueue: FMDatabaseQueue
    let executionQueue = DispatchQueue(label: "DAO-excute-queue", attributes: .concurrent)
    
    static let shared = DBHelper()
    private  init() {
        dbQueue = FMDatabaseQueue()
    }
    
    static func buildCreateTableSql(dbModel: DBModel.Type, dbName: String) -> String {
        let tableName = dbModel.dbTableName
        let cls = dbModel.dbColumns
        var lines = [String]()
        _ = cls.map { (k, v) in
            lines.append("\(k) \(v)")
        }
        var lineStr = lines.joined(separator: ",")
        if let pks = dbModel.dbPrimaryKeys {
            lineStr = "\(lineStr), PRIMARY KEY (\(pks.joined(separator: ","))) "
        }
        let sql = "CREATE TABLE IF NOT EXISTS \(dbName).\(tableName) (\(lineStr)) "
        return sql
    }
    
 
    func getDBModelVersion(dbName: String, completion: @escaping ([DBModelVersion]?)->(Void)) {
        let dao = BaseDao()
        dao.queryModel(DBModelVersion.self) { completion($0) }
    }
    
    
    /// 对比version 看是否需要升级。 此操作是基础的并且需要在最前面完成的，所有放在了一个 block中完成。
    ///
    /// - Parameters:
    ///   - dbModel: <#dbModel description#>
    ///   - dbName: <#dbName description#>
    func upgradeTable(dbModel: DBModel.Type, dbName: String) {
        self.dbQueue.inDatabase { (db) in
            let versionSql = Sql.select(dbName: dbName).table(DBModelVersion.dbTableName).build()
            var rs :FMResultSet? = nil
            
            let task = { (dbVersion: DBModelVersion?) in
                let sql = "PRAGMA \(dbName).table_info('\(dbModel.dbTableName)')"
                do {
                    rs = try db.executeQuery(sql, values: nil)
                    var columns = Set<String>()
                    while((rs?.next())!) {
                        if let column = rs?.string(forColumn: "name") {
                            columns.insert(column)
                        }
                    }
                    let existColumns = Set(dbModel.dbColumns.keys)
                    columns.subtract(existColumns)
                    
                    _ = columns.map {
                        let alterSql = "ALTER TABLE \(dbModel.dbTableName) ADD COLUMN \($0) \(dbModel.dbColumns[$0]?.rawValue ?? "") "
                        _ = try? db.executeUpdate(alterSql, values: nil)
                    }
                    
                    dbModel.dbUpgrade(from: dbVersion?.version ?? 0, dbName: dbName, db: db)

                } catch {
                    print(db.lastErrorMessage())
                }
            }
            
            let updateVersion = {
                let update = Sql.insert(dbName: dbName).build()
                try? db.executeUpdate(update, values: nil)
            }
            
            do {
                rs = try db.executeQuery(versionSql, values: nil)
                if let version = rs?.arrayOfModelType(DBModelVersion.self).first {
                    if version.version != dbModel.dbVersion {
                        task(version)
                        updateVersion()
                    }
                } else {
                    task(nil)
                    updateVersion()
                }
            } catch {
                print(db.lastErrorMessage())
            }
     
        }
     
    }
    
    func insertModel(_ model: Model, dbName: String, needBarrier: Bool = false, completion: ((Bool)->())?) {
        let modelType = type(of: model)
        let columKeys: [String] = Array(modelType.dbColumns.keys)
        guard let jsonStr = model.toJSONString() else {
            if let completion = completion {
                completion(false)
            }
            return
        }
        guard let dic = Dictionary<String, Any>.fromJSONString(jsonStr) else {
            if let completion = completion {
                completion(false)
            }
            return
        }
        var paramDic = [String : Any]()
        _ = columKeys.map {
            if let v = dic[$0] {
                paramDic[$0] = v
            }
        }
        let sql = Sql.insert(dbName: dbName).table(modelType.dbTableName).colums(columKeys).build()
        modify(sql: sql, paramDic: paramDic, needBarrier: needBarrier, completion: completion)
    }
    
    func deleteModel(_ model: Model, dbName: String, where: [String : Any], needBarrier: Bool = false, needTransation: Bool = false, completion: ((Bool)->())?) {
        let sql = Sql.delete(dbName: dbName).andWhere(Array(`where`.keys)).build()
        modify(sql: sql, paramDic: `where`, needBarrier: needBarrier, completion: completion)
    }
    
    func updateModel(_ modeType: Model.Type, dbName: String, columsDic: [String:Any], where: [String : Any], needBarrier: Bool = false, needTransation: Bool = false, completion: ((Bool)->())?) {
        let sql = Sql.update(dbName: dbName).table(modeType.dbTableName).colums(Array(columsDic.keys)).andWhere(Array(`where`.keys)).build()
        /// TODO: 当key 相同时有bug。
        let mergeDic = columsDic.merging(`where`) { $1 }
        modify(sql: sql, paramDic: mergeDic, needBarrier: needBarrier, completion: completion)
    }
    
    func modify(sqls: [String], paramDics:[[String : Any]], needBarrier: Bool = false, needTransation: Bool = false, completion: ((Bool)->())?) {
        guard sqls.count != paramDics.count else {
            if let completion = completion {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
            return
        }
        
        let task = {
            if needTransation {
                self.dbQueue.inTransaction { (db, rollback) in
                    for i in 0..<sqls.count {
                        let sql = sqls[i]
                        let paramDic = paramDics[i]
                        let success = db.executeUpdate(sql, withParameterDictionary: paramDic)
                        if !success {
                            rollback.pointee = true
                            print(db.lastErrorMessage())
                            break
                        }
                        
                        if let completion = completion, ((i + 1) == sql.count) {
                            DispatchQueue.main.async {
                                completion(success)
                            }
                        }
                    }
                }
            } else {
                self.dbQueue.inDatabase { (db) in
                    for i in 0..<sqls.count {
                        let sql = sqls[i]
                        let paramDic = paramDics[i]
                        let success = db.executeUpdate(sql, withParameterDictionary: paramDic)
                        if !success {
                            print(db.lastErrorMessage())
                            break
                        }
                        
                        if let completion = completion, ((i + 1) == sql.count) {
                            DispatchQueue.main.async {
                                completion(success)
                            }
                        }
                    }
                }
            }
        }
        
        if needBarrier {
            task()
        } else {
            executionQueue.async {
                task()
            }
        }
    }
    
    func modify(sql: String, paramDic:[String : Any], needBarrier: Bool = false, completion: ((Bool)->())?) {
        let task =  {
            self.dbQueue.inDatabase { (db) in
                let success = db.executeUpdate(sql, withParameterDictionary: paramDic)
                if !success {
                    print(db.lastErrorMessage())
                }
                if let completion = completion {
                    DispatchQueue.main.async {
                        completion(success)
                    }
                }
            }
        }
        
        if needBarrier {
            task()
        } else {
            executionQueue.async {
                task()
            }
        }
    }
    
    func queryModel<T: Model>(_ modelType: T.Type, dbName: String, completion: @escaping (([T]?)->())) {
        let sql = Sql.select(dbName: dbName).table(modelType.dbTableName).build()
        executionQueue.async {
            self.dbQueue.inDatabase { (db) in
                do {
                        let set = try db.executeQuery(sql, values: nil)
                        completion(set.arrayOfModelType(modelType))
                } catch {
                    print(db.lastErrorMessage())
                        completion(nil)
                }
            }
        }
    }
    
    /// where dictionary(key:colum'name,value 是对应的条件值) 多个值之间用 and
    func queryModel<T: Model>(_ modelType: T.Type, dbName: String, whereDic: [String:String], completion: (([T]?)->())?) {
        let sql = Sql.select(dbName: dbName).table(modelType.dbTableName).andWhere(Array(whereDic.keys)).build()
        query(sql: sql, modelType: modelType, paramDic: whereDic, completion: completion)
    }
    
    /// where dictionary(key:colum'name,value 是对应的条件值) 多个值之间用 OR
    func queryModel<T: Model>(_ modelType: T.Type, dbName: String, whereOrDic: [String:String], completion: (([T]?)->())?) {
        let sql = Sql.select(dbName: dbName).table(modelType.dbTableName).orWhere(Array(whereOrDic.keys)).build()
        query(sql: sql, modelType: modelType, paramDic: whereOrDic, completion: completion)
    }
    
    func query<T: Model>(sql: String, modelType: T.Type, paramDic: [String : Any],  completion: (([T]?)->())?) {
        executionQueue.async {
            self.dbQueue.inDatabase { (db) in
                if let completion = completion {
                    if let set = db.executeQuery(sql, withParameterDictionary: paramDic) {
                        let result = set.arrayOfModelType(modelType)
                        DispatchQueue.main.async {
                            completion(result)
                        }
                    } else {
                        print(db.lastErrorMessage())
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
}

