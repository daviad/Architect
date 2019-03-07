//
//  ModulesProtocol.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/2/28.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation

protocol ModuleProtocl {
    // 为了避免模块顺序引起的bug。才有了load 和setup
    //加载模块，实质就是创建对象
    func load()
    //设置模块，此时所有的模块都已经load完成
    func setup()
    
    var dbModels: [DBModel]? { get }
}

extension ModuleProtocl {
    func setup() {}
    func load() {}
    var dbModels: [DBModel]? { return nil }
}

