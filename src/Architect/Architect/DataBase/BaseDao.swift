//
//  BaseDao.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/4.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
import HandyJSON

typealias Model = HandyJSON & DBModel

class BaseDao {
    var accessor = ResAccessor.init(role: AppSession.shared.accessor.role)
    init(accessor_: ResAccessor) {
        accessor = accessor_
    }
    init() {
        
    }
    func insertModel(_ model: Model, replace: Bool = false, completion: ((Bool)->())?) {
        DBHelper.shared.insertModel(model, dbName: accessor.role.rawValue, replace: replace) { (success) in
            DispatchQueue.main.async {
                if let completion = completion {
                    completion(success)
                }
            }
        }
    }
    
    func deleteModel(_ model: Model, where: [String : Any], completion: ((Bool)->())?) {
        DBHelper.shared.deleteModel(model, dbName: accessor.role.rawValue, where: `where`) { (success) in
            DispatchQueue.main.async {
                if let completion = completion {
                    completion(success)
                }
            }
        }
    }
    
    func updateModel(_ model: (Model), completion: ((Bool)->())?) {
        self.insertModel(model, replace: true, completion: completion)
    }
    
    func queryModel<T: Model>(_ modelType: T.Type, completion: @escaping (([T]?)->())) {
        DBHelper.shared.queryModel(modelType, dbName: accessor.role.rawValue) { (result) in
            DispatchQueue.main.async { completion(result) }
        }
    }

    /// where string
    func queryModel<T: Model>(_ modelType: T.Type, where: String, completion: @escaping (([T]?)->())) {
        DBHelper.shared.queryModel(modelType, dbName: accessor.role.rawValue, whereString: `where`) { (result) in
             DispatchQueue.main.async { completion(result) }
        }
    }
    /// where dictionary(key:colum'name,value 是对应的条件值) 多个值之间用 and
    func queryModel<T: Model>(_ modelType: T.Type, whereDic: [String:String], completion: @escaping (([T]?)->())) {
        DBHelper.shared.queryModel(modelType, dbName: accessor.role.rawValue, whereDic: whereDic) { (result) in
            DispatchQueue.main.async { completion(result) }
        }
    }
    /// where dictionary(key:colum'name,value 是对应的条件值) 多个值之间用 OR
    func queryModel<T: Model>(_ modelType: T.Type, whereOrDic: [String:String], completion: @escaping (([T]?)->())) {
        DBHelper.shared.queryModel(modelType, dbName: accessor.role.rawValue, whereOrDic: whereOrDic) { (result) in
            DispatchQueue.main.async { completion(result)}
        }
    }
    
}
