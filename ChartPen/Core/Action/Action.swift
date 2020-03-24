//
//  Action.swift
//  ChartPen
//
//  Created by Yiqiang Zeng on 2020/3/24.
//  Copyright © 2020 Yiqiang Zeng. All rights reserved.
//

import UIKit

///// 动作

class Action {
    
    //MARK: - 声明区域
    var type: ActionType!
    var target: [CGPoint] = []
    
    init(type: ActionType) {
        self.type = type
        self.setup()
    }
    
    //MARK: - 私有成员
    fileprivate var pos: Int = 0
    fileprivate var loc: [Int] = []
    fileprivate var left: [CGPoint] = []
    fileprivate var right: [CGPoint] = []
    fileprivate var node: [CGPoint] = []
}

//MARK: - 事件处理
extension Action {
    
    // 初始化
    func setup() {
        switch type {
        case let .add_path_anchor(pos, node, left, right):
            self.pos = pos
            self.node = node
            self.left = left
            self.right = right
        case let .add_anchor(pos, node):
            self.pos = pos
            self.node = node
        case let .move_point(loc, node, target, _):
            self.loc = loc
            self.node = node
            self.target = target
        default:
            break
        }
    }
}

/// 动作类型

enum ActionType {
    case add_anchor(pos: Int, node: [CGPoint])                          // 添加锚点
    case add_path_anchor(pos: Int, node: [CGPoint], left: [CGPoint], right: [CGPoint])   // 添加路径锚点
    case move_point(loc: [Int], node: [CGPoint], target: [CGPoint], withAnchor: Bool)    // 移动点
}
