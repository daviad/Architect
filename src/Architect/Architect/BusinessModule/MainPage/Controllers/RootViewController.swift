//
//  RootViewController.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/2/28.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
import UIKit

class RootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green;
//        self.view.backgroundColor = .red
//        let configDic = ["module":["Module1","Module2"]]
//        let jsonData = try! JSONSerialization.data(withJSONObject: configDic, options: .prettyPrinted)
////        let jsonStr = String.init(data: jsonData, encoding: .utf8)!
////        let plainData = jsonStr.data(using: .utf8)
//        let base64String = jsonData.base64EncodedString()
////        let path = Bundle.main.path(forResource: "hybrid", ofType: "html")!;
////        let url = URL(fileURLWithPath: path+"?webconfig="+base64String)
//        let url = Bundle.main.url(forResource: "hybrid", withExtension: "html")
//        let urlStr = url?.absoluteString
////        let web = WebBrowerController(url: "https://www.baidu.com?webconfig="+base64String)
//        let web = WebBrowerController(url: urlStr!+"?webconfig="+base64String)
//        self.addChild(web)
//        self.view.addSubview(web.view)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.navigationController?.pushViewController(MonitorViewController(), animated: true);
    }
}
