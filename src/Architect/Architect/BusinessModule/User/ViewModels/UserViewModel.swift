//
//  UserViewModel.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/7.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
import Moya

//请求分类
enum UserRequest {
    case imgCode
    case smsCode(mobile: String, code: String)
    case regist(mobile: String, pwd: String)
    case getUser
}

//请求配置
extension UserRequest: TargetType {
    var baseURL: URL {
        return URL(string: "http://192.168.2.50:8088")!
    }
    
    var path: String {
        switch self {
        case .imgCode:
            return "/user/vCode?"
        case .smsCode(let mobile, let code):
            return "/user/code?mobile=\(mobile)&code=\(code)"
        case .regist(_,_), .getUser:
            return "/user/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .regist:
            return .post
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
        
    var task: Task {
        switch self {
        case .regist(let mobile, let pwd):
//            JSONEncoding.default
            return .requestParameters(parameters: ["mobile":mobile,"pwd":pwd], encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}

class Test {
    let provider = MoyaProvider<UserRequest>()
    func request() {
        provider.request(.imgCode) { (result) in
            print("sds")
        }
        
        
        provider.request(.regist(mobile: "12345678901", pwd: "123456")) { result in
            switch result {
            case let .success(response):
                //...............
                break
            case let .failure(error):
                //...............
                break
            }
        }
    }
   
}






//let publicParamEndpointClosure = { (target: UserService) -> Endpoint<UserService> in
//    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
//    let endpoint = Endpoint<UserService>(url: url, sampleResponseClosure: { .networkResponse(200, target.sampleData) }, method: target.method, parameters: target.parameters, parameterEncoding: target.parameterEncoding)
//    return endpoint.adding(newHTTPHeaderFields: ["x-platform" : "iOS", "x-interface-version" : "1.0"])
//}

//let provider = MoyaProvider(endpointClosure: publicParamEndpointClosure)
