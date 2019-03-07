//
//  DBProtocol.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/1.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation

protocol DBProtocol {
    
}

protocol DBModel {
    static var dbTableName: String { get }
    static var dbColumns: Dictionary<String, DBConstants.DataType> { get }
    static var dbPrimaryKeys: [String]? { get }
    static var dbVersion: Int { get }
}

extension DBModel {
    static var dbVersion: Int { return 0 }
    static var dbPrimaryKeys: [String]? { return nil }
}
