//
//  ResAccessor.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/1.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation

enum ResAccessRole: String {
    case Public = "pub"
    case User = "user"
    case All = "all"
}

struct ResAccessor {
    var role = ResAccessRole.Public

}
