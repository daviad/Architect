//
//  RxSwiftModule.swift
//  Architect
//
//  Created by liushuai on 2019/7/18.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

struct Wrapper<Base> {
    let base: Base
    init(_ base:Base) {
        self.base = base;
    }
    func sayToHumman() {
        print("\(self.base):hello");
    }
}

class BaseObj {
}

class Dog: BaseObj {
    func say() {
        print("wang wang")
    }
}

protocol Compatible {
    associatedtype CompatibleType
    var wr:Wrapper<CompatibleType> {get set}
}

extension Compatible {
    var wr:Wrapper<Self> {
        set{
            
        }
        get{
            return Wrapper(self)
        }
    }
    
}

extension BaseObj: Compatible {
    
}


extension Wrapper where Base: Dog {
    func sayDogToHumman() {
        print("ok")
    }
}



class RxSwiftModule: ModuleProtocl {
    func load() {
        enterApp()
        let observable = Observable.of("a","b","c")
//        observable.subscribe { (event) in
//            print(event.element)
//        }
        
        let d = Wrapper(Dog());
        d.sayToHumman();
        
        let d2 = Dog();
        d2.wr.sayDogToHumman();
    
        
        
      _ =  observable
            .do(onNext: { element in
                print("Intercepted Next：", element)
            }, onError: { error in
                print("Intercepted Error：", error)
            }, onCompleted: {
                print("Intercepted Completed")
            }, onDispose: {
                print("Intercepted Disposed")
            })
            .subscribe(onNext: { element in
                print(element)
            }, onError: { error in
                print(error)
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("disposed")
            })
        
        test1();
    }
    func enterApp() {
        let appdele = UIApplication.shared.delegate as! AppDelegate
        appdele.window?.rootViewController = UINavigationController.init(rootViewController: RxFirstController())
        
    }
    func test1() {
        let disposeBag = DisposeBag()
        
        //创建一个PublishSubject
        let subject = PublishSubject<String>()
        
        //由于当前没有任何订阅者，所以这条信息不会输出到控制台
        subject.onNext("111")
        
        //第1次订阅subject
        subject.subscribe(onNext: { string in
            print("第1次订阅：", string)
        }, onCompleted:{
            print("第1次订阅：onCompleted")
        }).disposed(by: disposeBag)
        
        //当前有1个订阅，则该信息会输出到控制台
        subject.onNext("222")
        
        //第2次订阅subject
        subject.subscribe(onNext: { string in
            print("第2次订阅：", string)
        }, onCompleted:{
            print("第2次订阅：onCompleted")
        }).disposed(by: disposeBag)
        
        //当前有2个订阅，则该信息会输出到控制台
        subject.onNext("333")
        
        //让subject结束
        subject.onCompleted()
        
        //subject完成后会发出.next事件了。
        subject.onNext("444")
        
        //subject完成后它的所有订阅（包括结束后的订阅），都能收到subject的.completed事件，
        subject.subscribe(onNext: { string in
            print("第3次订阅：", string)
        }, onCompleted:{
            print("第3次订阅：onCompleted")
        }).disposed(by: disposeBag)
    }
}
