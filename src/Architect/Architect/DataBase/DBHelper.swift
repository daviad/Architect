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
        
        case PrimaryKey = "PRIMARY KEY"
        case notNull = "NOT NULL"
        case unique = "UNIQUE"
    }
    
    //    static let text = "TEXT"
    //    static let integer = "INTEGER"
    //    static let bool = "INTEGER"
    //    static let real = "REAL"
    //    static let bigInt = "BIGINT"
    //    static let blob = "BLOB"
    
    //    static let PrimaryKey = "PRIMARY KEY"
    //    static let notNull = "NOT NULL"
    //    static let unique = "UNIQUE"
    
    static func columnConstraint(constraint: Any) -> String {
        var cols = String()
        if type(of: constraint) == DBConstants.DataType.self {
            let def = constraint as! DataType
            cols.append(def.rawValue)
        }
        if type(of: constraint) == Array<DBConstants.DataType>.self {
            let array = constraint as! Array<DBConstants.DataType>
            _ = array.map { (a) in
                cols.append(" \(a.rawValue)")
            }
        }
        return cols
    }
}


extension FMResultSet {
    /// 将next(),close封装起来以免遗漏
    /// - Parameter block: next() 后的执行，返回值说明是否停止next。
    func enumrate(block: () -> (Bool) ) {
        while self.next() {
            if block() {
                break
            }
        }
        self.close()
    }
    
    func enumerate<T: Model>(_ modelType: T.Type, _ results: inout [T]) {
        self.enumrate { () -> (Bool) in
            let dic = self.resultDictionary as? [String : Any]
            if let model = modelType.deserialize(from: dic) {
                results.append(model as T)
            }
            return false
        }
    }
    
    func arrayOfModelType<T: Model>(_ modelType: T.Type) -> [T] {
        var results = [T]()
        enumerate(modelType, &results)
        return results
    }
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
        var cls = [String : String]()
        _ = dbModel.dbColumns.map { (k,v) in
            cls[k] = DBConstants.columnConstraint(constraint: v)
        }
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
            let updateVersion = { (dbVersion: DBModelVersion) in
                let replace = Sql.repace(dbName: dbName).table(DBModelVersion.dbTableName).colums(Array(DBModelVersion.dbColumns.keys)).build()
                db.executeUpdate(replace, withParameterDictionary: ["name": dbVersion.name, "version":dbVersion.version])
            }
            var rs :FMResultSet? = nil
            let task = { (dbVersion: DBModelVersion?) in
                let sql = "PRAGMA \(dbName).table_info('\(dbModel.dbTableName)')"
                do {
                    rs = try db.executeQuery(sql, values: nil)
                    var columns = Set<String>()
                    rs?.enumrate(block: { () -> (Bool) in
                        if let column = rs?.string(forColumn: "name") {
                            columns.insert(column)
                        }
                        return false
                    })
                    
                    var newColumns = Set(dbModel.dbColumns.keys)
                    newColumns.subtract(columns)
                    
                    _ = newColumns.map {
                        let alterSql = "ALTER TABLE \(dbName).\(dbModel.dbTableName) ADD COLUMN \($0) \(DBConstants.columnConstraint(constraint: dbModel.dbColumns[$0] as Any)) "
                        _ = try? db.executeUpdate(alterSql, values: nil)
                    }
                    
                    dbModel.dbUpgrade(from: dbVersion?.version ?? 0, dbName: dbName, db: db)
                    
                    if dbVersion == nil {
                        updateVersion(DBModelVersion(name: dbModel.dbTableName, version: 0))
                    }
                    
                } catch {
                    print(db.lastErrorMessage())
                }
            }
            
            do {
                rs = try db.executeQuery(versionSql, values: nil)
                if let version = rs?.arrayOfModelType(DBModelVersion.self).first {
                    if version.version != dbModel.dbVersion {
                        task(DBModelVersion(name: dbModel.dbTableName, version: dbModel.dbVersion))
                        updateVersion(DBModelVersion(name: dbModel.dbTableName, version: dbModel.dbVersion))
                    }
                } else {
                    task(nil)
                }
            } catch {
                print(db.lastErrorMessage())
            }
        }
        
    }
    
    func insertModel(_ model: Model, dbName: String, needBarrier: Bool = false, replace: Bool = false, completion: ((Bool)->())?) {
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
        var sql: String
        if replace {
            sql = Sql.repace(dbName: dbName).table(modelType.dbTableName).colums(columKeys).build()
        } else {
            sql = Sql.insert(dbName: dbName).table(modelType.dbTableName).colums(columKeys).build()
        }
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
    
//    func updateMode(_ modeType: Model.Type, dbName: String, whereStr: String, needBarrier: Bool = false, completion: ((Bool)->())?) {
//        let sql = Sql.update(dbName: dbName).table(modeType.dbTableName).colums(<#T##colums: [String]##[String]#>)
//    }
    
    func modify(sqls: [String], paramDics:[[String : Any]], needBarrier: Bool = false, needTransation: Bool = false, completion: ((Bool)->())?) {
        guard sqls.count != paramDics.count else {
            if let completion = completion {
                completion(false)
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
                            completion(success)
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
                            completion(success)
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
                    completion(success)
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
    /// no where
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
    func queryModel<T: Model>(_ modelType: T.Type, dbName: String, whereDic: [String:String], completion: @escaping (([T]?)->())) {
        let sql = Sql.select(dbName: dbName).table(modelType.dbTableName).andWhere(Array(whereDic.keys)).build()
        query(sql: sql, modelType: modelType, paramDic: whereDic, completion: completion)
    }
    
    /// where dictionary(key:colum'name,value 是对应的条件值) 多个值之间用 OR
    func queryModel<T: Model>(_ modelType: T.Type, dbName: String, whereOrDic: [String:String], completion: @escaping (([T]?)->())) {
        let sql = Sql.select(dbName: dbName).table(modelType.dbTableName).orWhere(Array(whereOrDic.keys)).build()
        query(sql: sql, modelType: modelType, paramDic: whereOrDic, completion: completion)
    }
    /// where string
    func queryModel<T: Model>(_ modelType: T.Type, dbName: String, whereString: String, completion: @escaping (([T]?)->())) {
        let sql = Sql.select(dbName: dbName).table(modelType.dbTableName).whereStatement(whereString).build()
        query(sql: sql, modelType: modelType, paramDic: [String : Any](), completion: completion)
    }
    
    func query<T: Model>(sql: String, modelType: T.Type, paramDic: [String : Any],  completion: @escaping (([T]?)->())) {
        executionQueue.async {
            self.dbQueue.inDatabase { (db) in
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


