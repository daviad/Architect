//
//  SqlStatement.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/4.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation

class Sql {
    fileprivate let dbName_:    String
    private(set) var table_:     String? //select 可能是有多个table 所以 optional
    private(set) var colums_:    [String]?
    
    /// 目前这三个属性where 只能同时满足一个
    private(set) var where_:     String?
    private(set) var andWhere_:  [String]?
    private(set) var orWhere_:   [String]?
    
    lazy var realTable: String = {
        return "\(dbName_).\(table_!)"
    }()
    
    init(_ dbName: String) {
        dbName_ = dbName
    }
    
    //    @discardableResult
    static func insert(dbName: String) -> SqlInsert {
        return SqlInsert(dbName)
    }
    
    static func update(dbName: String) -> SqlUpdate {
        return SqlUpdate(dbName)
    }
    
    static func delete(dbName: String) -> SqlDelete {
        return SqlDelete(dbName)
    }
    
    static func select(dbName: String) -> SqlSelect {
        return SqlSelect(dbName)
    }
    
    func table(_ table: String) -> Self {
        table_ = table
        return self;
    }
    
    func colums(_ colums: [String]) -> Self {
        colums_ = colums
        return self
    }
    
    /// 目前这三个 where 只能同时满足一个
    func whereStatement(_ condition: String) -> Self {
        where_ = condition
        return self
    }
    
    func andWhere(_ andWhere: [String]) -> Self {
        andWhere_ = andWhere
        return self
    }
    
    func orWhere(_ orWhere: [String]) -> Self {
        orWhere_ = orWhere
        return self
    }
    
    class func buildWhere() -> String {
        return ""
    }
    
    func buildWhere() -> String {
        var sql :String = String()
        guard let wh = where_ else {
            if let andWhere = andWhere_ {
                sql.append(" where 1 = 1 ")
                _ = andWhere.map {
                    let line = " AND \($0) = :\($0) "
                    sql.append(line)
                }
            }
            if let orWhere = orWhere_ {
                if andWhere_ != nil {
                    
                } else {
                    sql.append(" where 1 = 2 ")
                }
                _ = orWhere.map {
                    let line = " OR \($0) = :\($0) "
                    sql.append(line)
                }
            }
            return sql
        }
        return sql.appending(" \(wh)")
        
    }
    
    func build() -> String {
        return ""
    }
}

final class SqlSelect: Sql {
    private(set) var tables_: [String]?
    private(set) var orderBy_: [(String,String)]?
    private(set) var groupBy_: [String]?
    private(set) var limitOffset: Int?
    private(set) var limitCount: Int?
    
    override lazy var realTable: String = {
        if let ts = tables_ {
            var rt: String = ""
            tables_.map {
                rt.append(contentsOf: "\(dbName_).\($0)  ")
            }
            return rt
        } else {
            return "\(dbName_).\(table_!)"
        }
    }()
    
    func orderBy(_ orderBy: [(String,String)]) -> Self {
        orderBy_ = orderBy
        return self
    }
    
    func groupBy(_ groupBy: [String]) -> Self {
        groupBy_ = groupBy
        return self
    }
    
    func limit(_ offset: Int, _ count: Int) -> Self {
        limitOffset = offset
        limitCount = count
        return self
    }
    
    override func build() -> String {
        var tbs = "*"
        if let cls = colums_ {
            tbs = cls.joined(separator: ",")
        }
        var sql = "SELECT \(tbs) FROM  \(realTable) "
        
        sql.append(buildWhere())
        
        //注：GROUP BY 子句使用时必须放在 WHERE 子句中的条件之后，必须放在 ORDER BY 子句之前。
        if let gb = groupBy_ {
            sql.append(contentsOf: " Group BY \(gb.joined(separator: ","))")
        }
        
        if let ob = orderBy_ {
            var tmpStr = ""
            _ = ob.map { kv in
                tmpStr.append(contentsOf: "\(kv.0) \(kv.1)")
            }
            sql.append(contentsOf: " ORDER BY \(tmpStr)")
        }
        
        if let offset = limitCount ,let cnt = limitCount {
            sql.append(contentsOf: " LIMIT \(offset) OFFSET \(cnt)")
        }
        
        return sql
    }
}

final class SqlInsert: Sql {
    override func build() -> String {
        var sql = "INSERT INTO \(realTable)"
        if let cls = colums_ {
            var cnames = [String]()
            var values = [String]()
            _ = cls.map {
                cnames.append($0)
                values.append(":\($0)")
            }
            sql.append("(")
            sql.append(cnames.joined(separator: ","))
            sql.append(") values (")
            sql.append(values.joined(separator: ","))
            sql.append(")")
        }
        sql.append(buildWhere())
        return sql;
    }
}

final class SqlUpdate: Sql {
    override func build() -> String {
        var sql = "UPDATE \(realTable) SET "
        if let cls = colums_ {
            _ = cls.map {
                sql.append("\($0) = :\($0) ")
            }
        }
        sql.append(buildWhere())
        return sql;
    }
}

final class SqlDelete: Sql {
    override func build() -> String {
        var sql = "DELETE FROM \(realTable) "
        sql.append(buildWhere())
        return sql;
    }
}

