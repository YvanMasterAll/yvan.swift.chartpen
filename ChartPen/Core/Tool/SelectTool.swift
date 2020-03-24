//
//  SelectTool.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/24.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit

/// 选中工具

class SelectTool: Tool {
    
    required init(panel: Panel) {
        self.panel = panel
    }
    
    func handle(event: Event) {
        switch event {
        default:
            break
        }
    }
   
    //MARK: - 私有成员
    fileprivate var panel: Panel!
}

//MARK: - 事件处理
extension SelectTool {
    
    // 切换工具时重置操作
    func reset() {
        
    }
}
