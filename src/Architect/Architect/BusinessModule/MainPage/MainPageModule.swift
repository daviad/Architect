//
//  File.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/2/28.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
import UIKit
class MainPageModule: ModuleProtocl {
    func load() {
       enterApp()
    }
    func enterApp() {
        let appdele = UIApplication.shared.delegate as! AppDelegate
//        appdele.window?.rootViewController = UINavigationController.init(rootViewController: RootViewController())
        appdele.window?.rootViewController = RootViewController()
        
    }
}
