//
//  MonitorViewController.swift
//  Architect
//
//  Created by liushuai on 2019/7/11.
//  Copyright © 2019年  dingxiuwei. All rights reserved.
//

import UIKit
import SnapKit

class MonitorViewController: UIViewController {
    private let fps = FPS();
    private let fpsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40));
    private let cupLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40));
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.addSubview(fpsLabel);
        fps.updateBlk = { [weak self] in
            self?.fpsLabel.text = "FPS: \(round(self?.fps.fps ?? 0))"
        };
        cupLabel.text = "cup: \(123)";
        self.view.addSubview(cupLabel);
    }
    deinit {
        print("deinit")

    }
 


}
