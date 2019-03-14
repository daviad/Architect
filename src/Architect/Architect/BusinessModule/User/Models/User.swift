//
//  User.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/4.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
import HandyJSON

enum Gender: UInt8, HandyJSONEnum {
    case other = 0
    case Man = 1
    case Female = 2
}

struct User: HandyJSON {
    var name: String!
    var id: Int!
    var age: Int?
    var gender: Gender?
    var vip: Bool = false
}

extension User: DBModel {
    static var dbVersion: Int {
        return 3
    }
    
    static var dbTableName: String {
        return "user"
    }
    
    static var dbColumns: Dictionary<String, Any> {
        return [
            "id"        : [DBConstants.DataType.integer,DBConstants.DataType.PrimaryKey],
            "name"      : DBConstants.DataType.text,
            "age"       : DBConstants.DataType.integer,
            "gender"    : DBConstants.DataType.integer,
            "vip"       : DBConstants.DataType.bool,
            "test"      : DBConstants.DataType.text,
            "test2"     : DBConstants.DataType.text

        ]
    }
//    static var dbPrimaryKeys: [String]? {
//        return ["id"]
//    }

}
