//
//  DBModelVersion.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/11.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
import HandyJSON

struct DBModelVersion: HandyJSON {
    var name    :String!
    var version :Int!
}

extension DBModelVersion: DBModel {
    static var dbPrimaryKeys: [String]? { return ["name"] }
    
    static var dbTableName: String {
        return "dbversion"
    }
    
    static var dbColumns: Dictionary<String, DBConstants.DataType> {
        return [
            "name"    : .text,
            "version"     : .integer
        ]
    }
}
