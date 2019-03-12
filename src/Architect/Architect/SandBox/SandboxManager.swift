//
//  SandboxManager.swift
//  Architect
//
//  Created by  dingxiuwei on 2019/3/1.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation

enum SandBoxDirType {
    case document
    case cache
    case tmp
}

final class SandboxManager {
    
    static let shared = SandboxManager()
    private init() {}
    
    lazy var homeDir: String = {
        return NSHomeDirectory()
    }()
    
    lazy var documentDir: String = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let p = path {
            return p
        } else {
            return NSTemporaryDirectory()
        }
    }()
    
    lazy var cacheDir: String = {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        if let p = path {
            return p
        } else {
            return NSTemporaryDirectory()
        }
    }()
    
    lazy var tmpDir: String = {
        return NSTemporaryDirectory()
    }()
    
    func buildFolderPath(_ dir: String, _ folderName: String) -> String {
        let folderPath = (dir as NSString).appendingPathComponent(folderName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: folderPath, isDirectory: nil) {
            do {
                try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error as Any)
            }
        }
        return folderPath
    }
    
    func buildFolderPath(type: SandBoxDirType, _ folderName: String) -> String? {
        var dir: String?
        switch type {
        case .document:
            dir = documentDir
        case .cache:
            dir = cacheDir
        case .tmp:
            dir = tmpDir
        }
        if let dirTmp = dir {
           dir = buildFolderPath(dirTmp, folderName)
        }
        return dir
    }
}
