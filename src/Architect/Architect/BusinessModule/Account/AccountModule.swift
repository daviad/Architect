//
//  AccountModule.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/2/28.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
class AccountModule: ModuleProtocl {
    var dbModels: [DBModel] {
        return [Account()]
    }
    
    func load() {
        
    }
    
}
