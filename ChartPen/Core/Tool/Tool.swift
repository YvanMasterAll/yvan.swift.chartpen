//
//  Tool.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/24.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit

protocol Tool {
    func handle(event: Event)
    func reset()
}

// 工具类型
enum ToolType: String {
    case pen
    case select
    case undo
    case submit
    case delete
    case empty
    
    init(_ value: String) {
        switch value {
        case ToolType.pen.value     : self = .pen
        case ToolType.select.value  : self = .select
        case ToolType.undo.value    : self = .undo
        case ToolType.submit.value  : self = .submit
        case ToolType.delete.value  : self = .delete
        default                     : self = .empty
        }
    }
    
    var value: String {
        return self.rawValue
    }
}

// 事件类型
enum Event {
    case pan(ges: UIPanGestureRecognizer)               // 拖动
    case longPress(ges: UILongPressGestureRecognizer)   // 长按
    case tap(ges: UIPanGestureRecognizer)               // 单机
    case doubleTap                                      // 双击
    case swipeUp(ges: UISwipeGestureRecognizer)         // 上滑
    case swipeDown(ges: UISwipeGestureRecognizer)       // 下滑
    case swipeLeft(ges: UISwipeGestureRecognizer)       // 左滑
    case swipeRight(ges: UISwipeGestureRecognizer)      // 右滑
    case pinch(ges: UIPinchGestureRecognizer)           // 捏合
    case rotation(res: UIRotationGestureRecognizer)     // 旋转
    case touchesBegan(point: CGPoint)                   // 触屏开始
    case undo                                           // 撤销
}
