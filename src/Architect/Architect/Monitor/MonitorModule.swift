//
//  MonitorModule.swift
//  Architect
//
//  Created by  liushuai on 2019-07-11.
//  Copyright © 2019年  Company. All rights reserved.
//

import Foundation
import UIKit

class MonitorModule: ModuleProtocl {
    func setup() {
        let appdele = UIApplication.shared.delegate as! AppDelegate;
        let win = UIWindow(frame: CGRect(x: 9, y: 90, width: 100, height: 80));
        win.backgroundColor = UIColor.red;
        win.windowLevel = .normal;
        win.rootViewController = MonitorViewController();
        win.isHidden = false;
        appdele.window?.addSubview(win);

    }
}  
