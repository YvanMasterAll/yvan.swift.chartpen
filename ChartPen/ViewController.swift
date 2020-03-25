//
//  ViewController.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/22.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit
import BezierKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
}

//MARK: - 初始化
extension ViewController {
    
    fileprivate func setupUI() {
        // 面板容器
        let container = UIView()
//        self.view.addSubview(container)
//        container.snp.makeConstraints { make in
//            make.top.equalTo(self.view)
//            make.right.equalTo(self.view)
//            make.left.equalTo(self.view)
//            make.bottom.equalTo(self.view).offset(-toolbar_height)
//        }
        container.layer.masksToBounds = true
        // 绘图面板
        let panel = Panel()
        panel.backgroundColor = .white
        container.addSubview(panel)
        panel.snp.makeConstraints { make in
            make.top.equalTo(container)
            make.right.equalTo(container)
            make.left.equalTo(container)
            make.bottom.equalTo(container)
        }
        panel.tag = 10001
        // 工具栏
        let toolbar = ToolBar()
        toolbar.delegate = panel
        toolbar.setupTools(panel: panel)
        self.view.addSubview(toolbar)
        toolbar.snp.makeConstraints { make in
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(toolbar_height)
        }
        // 缩放控件
        let zoomView = ZoomView()
        self.view.addSubview(zoomView)
        zoomView.snp.makeConstraints { make in
            make.top.equalTo(self.view)
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-toolbar_height)
        }
        zoomView.loadView(target: container)
    }
}
