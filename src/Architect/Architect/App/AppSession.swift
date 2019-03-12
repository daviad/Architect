//
//  AppSession.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/1.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation

//存放app 相关的信息
final class AppSession {
    static let shared = AppSession()
    private  init() {}
    
    let accessor = ResAccessor.init(role: .Public)
    let user = User.init(name: "0", id: 0, age: 0, gender: nil, vip: false)
}
