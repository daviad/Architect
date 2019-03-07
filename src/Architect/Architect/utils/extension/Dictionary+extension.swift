//
//  Dictionary+extension.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/5.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation

extension Dictionary {
   static func fromJSONString(_ jsonString:String) -> Dictionary? {
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if  dict != nil {
            return (dict as! Dictionary)
        }
        return nil
    }
    
    func getArrayFromJSONString(jsonString:String) ->NSArray{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if array != nil {
            return array as! NSArray
        }
        return array as! NSArray
        
    }

}
