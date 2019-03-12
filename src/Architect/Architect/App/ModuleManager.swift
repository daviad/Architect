//
//  ModuleManager.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/2/28.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import UIKit

final class ModuleManager {
    static let shared = ModuleManager()
    private  init() {}
    
    //    TODO: 此处可以通过反射 写在配置文件生成  或不用反射 结合脚本生成代码  提高效率
    //    let modules: [ModuleProtocl] = [MainPageModule(),UserModule()]
    //    是否将 module 分类 比如 必须先加载的？
    private(set) var modules: [ModuleProtocl] = [ModuleProtocl]() //做成只读的
    
    func loadModules() {
        let mainPage = MainPageModule()
        mainPage.load()
        modules.append(mainPage)
        
        let userModule = UserModule()
        userModule.load()
        modules.append(userModule)
        
        let dataBaseModule = DataBaseModule()
        dataBaseModule.load()
        modules.append(dataBaseModule)
        
        _ = modules.map{ $0.setup() }
    }
}
