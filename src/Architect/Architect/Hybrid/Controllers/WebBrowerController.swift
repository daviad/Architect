//
//  WebBrowerController.swift
//  Architect
//
//  Created by 丁秀伟 on 2019/3/23.
//  Copyright © 2019  dingxiuwei. All rights reserved.
//

import UIKit
import WebKit

protocol WebBrowerDelegate {
    func configWebView(_ config: WKWebViewConfiguration);
}

class FeakModule: UIViewController, WebBrowerDelegate {
    var web: WKWebView!
    func configWebView(_ config: WKWebViewConfiguration) {
        //        ///偏好设置
        //        let preferences = WKPreferences()
        //        //preferences.javaScriptEnabled = true
        //        let configuration = WKWebViewConfiguration()
        //        configuration.preferences = preferences
        //        //        configuration.selectionGranularity = WKSelectionGranularity.character
        //        configuration.userContentController = WKUserContentController()
        ////         configuration.userContentController.add(self, name: "logger")
        //        let web_ = WKWebView(frame: .zero, configuration: configuration)
    }
    

}

let webconfig = "webconfig" //和服务器约定
class WebBrowerController: UIViewController,WKScriptMessageHandler {
    
    var url: URL!
    var delegates = [WebBrowerDelegate]()
    
    lazy var web: WKWebView = {
        let web_ = WKWebView()
        web_.configuration.userContentController.add(self, name: webconfig) //url注册和这个注册 二选一
        return web_
    }()
    

    init(url: String) {
        super.init(nibName:nil, bundle:nil)
        guard let components = URLComponents(string: url) else {
            assertionFailure("malformed url: \(url)")
            return
        }
        self.url = URL(string: url)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
//            self.config(self.parseConfig(components.queryItems))
//        }
       config(parseConfig(components.queryItems))
    }
    
    init(url: URL) {
        super.init(nibName:nil, bundle:nil)
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            assertionFailure("malformed url: \(url)")
            return
        }
        self.url = url
        config(parseConfig(components.queryItems))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.view.addSubview(web)
        web.frame = self.view.bounds
        web.load(URLRequest(url: self.url))
    }
    
    func config(_ serverDic: Dictionary<String,Array<String>>?) {
        if let modules = serverDic?["module"] {
            _ = modules.map { module in
                let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"]as! String
                let clsName = namespace + "." + module
                let cls = NSClassFromString(clsName) as! FeakModule.Type
                let instance = cls.init()
                instance.web = web
                instance.configWebView(web.configuration)
            }
        }
    }
    
    func parseConfig(_ queryPairs: [URLQueryItem]?) -> Dictionary<String,Array<String>>? {
        var dic: Dictionary<String,Array<String>>? = nil
        _ = queryPairs?.map {
            if $0.name == webconfig, let value = $0.value {
                if  let data = Data(base64Encoded: value) {
                    dic = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? Dictionary<String,Array<String>>
                }
            }
        }
        return dic
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == webconfig {
            config(message.body as? Dictionary<String,Array<String>>)
        }
    }
}
