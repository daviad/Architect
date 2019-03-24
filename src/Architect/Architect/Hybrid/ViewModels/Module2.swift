//
//  Module2.swift
//  Architect
//
//  Created by 丁秀伟 on 2019/3/23.
//  Copyright © 2019  dingxiuwei. All rights reserved.
//

import UIKit
import WebKit

class Module2: FeakModule, WKScriptMessageHandler {
    override func configWebView(_ config: WKWebViewConfiguration) {
        print("module2 config webview")
        config.userContentController.add(self, name: "module2_func1")

    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "module2_func1" {
            print("js call ios module2_func1")
        }
    }
}
