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
    //数据库的相关操作。  需要数据库的模块才需要这个这个属性，按理说应该再建一个协议（DBModuleProtocl），但是那样写的话使用好麻烦，目前我没有找到一个更好的方式。就是说如何完成数组中的元素可以分别实现不同的协议。（Any ,继承协议，都需要强转，感觉泛型好像可以，学艺不精，没写出来）
    var dbModels: [DBModel]? { get }
}

extension ModuleProtocl {
    func setup() {}
    func load() {}
    var dbModels: [DBModel]? { return nil }
}

