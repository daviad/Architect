//
//  CADisplayLink+extension.swift
//  Architect
//
//  Created by liushuai on 2019/7/12.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
import UIKit
class WeakDisplayLink {
    var actonBlk: (()->Void)? ;
    class func displayLink(block: @escaping ()->Void) -> CADisplayLink {
        let link = WeakDisplayLink();
        link.actonBlk = block;
        let tmpLink = CADisplayLink(target: link, selector: #selector(linkAction));
        tmpLink.add(to: .current, forMode: .common);
        return tmpLink;
    }
    @objc func linkAction() {
        if let blk = self.actonBlk {
            blk();
        }
    }
    deinit {
    }
}

private var CADisplayLink_ActonBlk_Key = "CADisplayLink_ActonBlk_Key";

extension CADisplayLink {
    var actonBlk: (()->Void)? {
        get {
            return objc_getAssociatedObject(self, &CADisplayLink_ActonBlk_Key) as? (()->Void)
        }
        set {
            objc_setAssociatedObject(self, &CADisplayLink_ActonBlk_Key, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
}

