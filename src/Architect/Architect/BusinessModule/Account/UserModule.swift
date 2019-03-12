//
//  UserModule.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/2/28.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
class UserModule: ModuleProtocl {
    var dbModels: [DBModel]? {
        return [User()]
    }
    
    func load() {
    }
    
}
