//
//  Module1.swift
//  Architect
//
//  Created by 丁秀伟 on 2019/3/23.
//  Copyright © 2019  dingxiuwei. All rights reserved.
//

import UIKit
import WebKit

class Module1: FeakModule, WKScriptMessageHandler {
    override func configWebView(_ config: WKWebViewConfiguration) {
        print("module1 config webview")
        config.userContentController.add(self, name: "module1_func1")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "module1_func1" {
            print("js call ios module1_func1")
            if let dic = (message.body as? Dictionary<String,String>), let callBack = dic["callBack"]  {
                let jsString = "js need content"
                let callBackString = callBack + "('\(jsString)')"
                web.evaluateJavaScript(callBackString) { (result, err) in
                    print(result ?? "sd")
                }
            }
        }
    }
}
