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
    fileprivate func enumerate(_ modelType: (Model).Type, _ results: inout [Model]) {
        while self.next() {
            let dic = self.resultDictionary as? [String : Any]
            if let model = modelType.deserialize(from: dic) {
                results.append(model as Model)
            }
        }
        self.close()
    }
    
    func arrayOfModelType(_ modelType: Model.Type) -> [Model] {
        var results = [Model]()
        enumerate(modelType, &results)
        return results
    }
}

extension Dictionary {
    //    func
}

struct DBHelper {
    
    let dbQueue: FMDatabaseQueue
    let executionQueue = DispatchQueue(label: "DAO-excute-queue", attributes: .concurrent)
    
    static let shared = DBHelper()
    private  init() {
        dbQueue = FMDatabaseQueue()
    }
    
    static func buildCreateTableSql(dbModel: DBModel.Type, dbName: String) -> String {
        let tableName = dbModel.dbTableName
        let cls = dbModel.dbColumns
        var lines = ""
        _ = cls.map { (k, v) in
            lines.append("\(k) \(v)")
        }
        if let pks = dbModel.dbPrimaryKeys {
            lines = "\(lines) PRIMARY KEY (\(pks.joined(separator: ","))) "
        }
        let sql = "CREATE TABLE IF NOT EXISTS \(dbName).\(tableName) (\(lines)) "
        return sql
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
    
    func queryModel(_ modelType: Model.Type, dbName: String, completion: (([Model]?)->())?) {
        let sql = Sql.select(dbName: dbName).table(modelType.dbTableName).build()
        executionQueue.async {
            self.dbQueue.inDatabase { (db) in
                do {
                    if let completion = completion {
                        let set = try db.executeQuery(sql, values: nil)
                        completion(set.arrayOfModelType(modelType))
                    }
                } catch {
                    print(db.lastErrorMessage())
                    if let completion = completion {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    /// where dictionary(key:colum'name,value 是对应的条件值) 多个值之间用 and
    func queryModel(_ modelType: Model.Type, dbName: String, whereDic: [String:String], completion: (([Model]?)->())?) {
        let sql = Sql.select(dbName: dbName).table(modelType.dbTableName).andWhere(Array(whereDic.keys)).build()
        query(sql: sql, modelType: modelType, paramDic: whereDic, completion: completion)
    }
    
    /// where dictionary(key:colum'name,value 是对应的条件值) 多个值之间用 OR
    func queryModel(_ modelType: Model.Type, dbName: String, whereOrDic: [String:String], completion: (([Model]?)->())?) {
        let sql = Sql.select(dbName: dbName).table(modelType.dbTableName).orWhere(Array(whereOrDic.keys)).build()
        query(sql: sql, modelType: modelType, paramDic: whereOrDic, completion: completion)
    }
    
    func query(sql: String, modelType: Model.Type, paramDic: [String : Any],  completion: (([Model]?)->())?) {
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

