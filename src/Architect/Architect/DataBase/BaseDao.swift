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

struct BaseDao {
    let accessor = ResAccessor.init(role: .All)

    func insertModel(_ model: Model, completion: ((Bool)->())?) {
        DBHelper.shared.insertModel(model, dbName: accessor.role.rawValue, completion: completion)
    }
    
    func deleteModel(_ model: Model, where: [String : Any], completion: ((Bool)->())?) {
        DBHelper.shared.deleteModel(model, dbName: accessor.role.rawValue, where: `where`, completion: completion)
    }
    
    func updateModel(_ model: (Model), completion: ((Bool)->())?) {
        
    }
    
    
    func queryModel(_ modelType: Model.Type, completion: (([Model]?)->())?) {
        DBHelper.shared.queryModel(modelType, dbName: accessor.role.rawValue, completion: completion)
    }
    
    /// where string
    func queryModel(_ modelType: Model.Type, where: String, completion: (([Model]?)->())?) {
        
    }
    /// where dictionary(key:colum'name,value 是对应的条件值) 多个值之间用 and
    func queryModel(_ modelType: Model.Type, whereDic: [String:String], completion: (([Model]?)->())?) {
        
    }
    /// where dictionary(key:colum'name,value 是对应的条件值) 多个值之间用 and
    func queryModel(_ modelType: Model.Type, whereOrDic: [String:String], completion: (([Model]?)->())?) {
        
    }
    
}
