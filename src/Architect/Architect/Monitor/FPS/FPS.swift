//
//  FPS.swift
//  Architect
//
//  Created by liushuai on 2019/7/11.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
import UIKit

class FPS : NSObject{
    var fps = 0.0;
    var updateBlk: (()->Void)?;
    private var displayLink: CADisplayLink = CADisplayLink();
    private var count = 0;
    private var lastTimestamp: CFTimeInterval = 0;
    override init() {
        super.init();
        displayLink = WeakDisplayLink.displayLink { [unowned self] in
            self.tick()
        }
        displayLink.add(to: .current, forMode: .common);
        if #available(iOS 10.0, *) {
            displayLink.preferredFramesPerSecond = 0;
        } else {
            displayLink.frameInterval = 1;
        }
    }
    
    deinit {
        displayLink.invalidate();
    }
    
    @objc private func tick() {
        guard lastTimestamp != 0 else {
            lastTimestamp = displayLink.timestamp;
            return;
        }

        count += 1;
        let delta = displayLink.timestamp - lastTimestamp;
        guard delta >= 1.0 else {
            return;
        }
        lastTimestamp = displayLink.timestamp;
        //  次数/时间
        fps = Double(count) / delta ;
        if let update = updateBlk {
            update();
        }
        count = 0;
    }
}
