//
//  RxFirstController.swift
//  Architect
//
//  Created by liushuai on 2019/7/18.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

struct UserViewModel {
    let userName = Variable("guest")
    lazy var userInfo = {
        return self.userName.asObservable().map{
            $0 == "admin" ? "你是管理员":"你是访客"
        }.share(replay:1)
    }()
}

class RxFirstController: UIViewController {
 let disposeBag = DisposeBag();
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white;
        let btn =  UIButton(frame: CGRect(x: 10, y: 80, width: 70, height: 50));
        self.view.addSubview(btn)
        btn.backgroundColor = .red;
       
        btn.rx.tap.subscribe(onNext: {
                print("button Tapped")
            }).disposed(by: disposeBag);
        
        let label = UILabel();
        self.view.addSubview(label);
        label.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: 100, height: 30));
            maker.top.equalTo(btn.snp.bottom).offset(2);
        }
        label.backgroundColor = .red;
        let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance);
        timer.map{
            String(format: "%0.2d:%0.2d.%0.1d",arguments: [($0 / 600) % 600, ($0 % 600 ) / 10, $0 % 10])
        }.bind(to: label.rx.text).disposed(by: disposeBag)
        
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height:   40))
        textField.backgroundColor = .red
        self.view.addSubview(textField)
        textField.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: 200, height: 40))
            maker.top.equalTo(label.snp.bottom).offset(2)
        }
        
        textField.rx.text.orEmpty.asObservable().subscribe(onNext: {
            print("\($0)")
        }).disposed(by: disposeBag)
    
        let outputField = UITextField()
        outputField.borderStyle = .roundedRect
        self.view.addSubview(outputField)
        outputField.snp.makeConstraints { (maker) in
            maker.top.equalTo(textField.snp.bottom).offset(2)
            maker.size.equalTo(CGSize(width: 180, height: 40))
        }
        
        let input = textField.rx.text.orEmpty.asDriver().throttle(0.3)
        input.drive(outputField.rx.text).disposed(by: disposeBag)
        
        let userNameField = UITextField();
        userNameField.borderStyle = .roundedRect
        self.view.addSubview(userNameField)
        userNameField.snp.makeConstraints { (maker) in
            maker.size.equalTo(CGSize(width: 100, height: 40))
            maker.top.equalTo(outputField.snp.bottom).offset(2)
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
