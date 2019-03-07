//
//  Account.swift
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

struct Account: HandyJSON {
    var name: String!
    var id: Int!
    var age: Int?
    var gender: Gender?
    var vip: Bool = false
}

extension Account: DBModel {
    static var dbVersion: Int {
        return 1
    }
    
    static var dbTableName: String {
        return "account"
    }
    
    static var dbColumns: Dictionary<String, DBConstants.DataType> {
        return [
            "id"      : .integer,
            "name"    : .text,
            "age"     : .integer,
            "gender"  : .integer,
            "vip"     : .bool
        ]
    }
}
