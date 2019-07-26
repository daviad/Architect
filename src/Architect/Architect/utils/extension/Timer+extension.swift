//
//  Timer+extension.swift
//  Architect
//
//  Created by liushuai on 2019/7/12.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation

extension Timer {
    
    open class func weak_scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) -> Timer {
        if #available(iOS 10.0, *) {
            return Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block);
        } else {
            return Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerActon), userInfo: block, repeats: repeats)
        }
    }
    
    @objc class func timerActon(_ sender: Timer) {
        if let block = sender.userInfo as? ((Timer)-> Void) {
            block(sender);
        }
    }
    

}
